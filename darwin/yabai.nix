{
  config,
  pkgs,
  lib,
  ...
}:

let
  yabai = "${pkgs.yabai}/bin/yabai";
  jq = "${pkgs.jq}/bin/jq";

  # Accessibility is granted to a path and a code signature. A store path and its ad-hoc signature
  # change on every yabai build, so launchd runs a copy at a fixed path, signed with a local
  # certificate that activation creates once in the system keychain.
  stable = "/usr/local/libexec/yabai/yabai";
  identity = "yabai-cert";
  keychain = "/Library/Keychains/System.keychain";
  user = config.system.primaryUser;

  # A window the size of the screen goes back to filling it when moved. Gridding a window that is
  # already in place does not move it, so this does not fire again.
  snap-back = pkgs.writeShellScript "yabai-snap-back" ''
    window=$(${yabai} -m query --windows --window "$YABAI_WINDOW_ID") || exit 0
    display=$(${yabai} -m query --displays --window "$YABAI_WINDOW_ID") || exit 0

    ${jq} -en --argjson w "$window" --argjson d "$display" '
      ($w."is-native-fullscreen" | not)
      and $w.frame.w >= $d.frame.w - 16 and $w.frame.h >= $d.frame.h - 160
    ' >/dev/null || exit 0

    ${yabai} -m window "$YABAI_WINDOW_ID" --grid 1:1:0:0:1:1
  '';

  # services.yabai would write this file too, but launchd has to run it with the signed copy.
  yabairc = pkgs.writeScript "yabairc" ''
    yabai -m config layout float
    yabai -m config mouse_follows_focus off
    yabai -m config focus_follows_mouse off

    yabai -m config mouse_modifier alt
    yabai -m config mouse_action1 move
    yabai -m config mouse_action2 resize

    yabai -m signal --add label=snap-back event=window_moved action="${snap-back}"

    yabai -m rule --add app="^Zed$" space=2
    yabai -m rule --apply
  '';
in
{
  # yabai 7.1.25 has no macOS 27 support, and `space --focus` silently does nothing there. This fork
  # switches spaces with a synthesised dock swipe that works with SIP enabled.
  # https://github.com/asmvik/yabai/issues/2822
  nixpkgs.overlays = [
    (final: prev: {
      yabai = prev.yabai.overrideAttrs (old: {
        src = final.fetchFromGitHub {
          owner = "YazeedAlKhalaf";
          repo = "yabai";
          rev = "9d6104a01fcba61ab4a19e5c19931da9efc76a7a";
          hash = "sha256-eo+bU3k93rXnDDmefscC8AjxDvv08hs9B6bfqqPgdQ0=";
        };
        # The fork commit has no release tag, so `yabai --version` does not match the version string.
        doInstallCheck = false;
      });
    })
  ];

  services.yabai.enable = true;

  launchd.user.agents.yabai.serviceConfig.ProgramArguments = lib.mkForce [
    stable
    "-c"
    "${yabairc}"
  ];

  system.activationScripts.extraActivation.text = ''
    if ! security find-certificate -c ${identity} ${keychain} >/dev/null 2>&1; then
      echo "creating the ${identity} code signing certificate..."
      cert=$(mktemp -d)
      printf '%s\n' \
        '[req]' 'distinguished_name = dn' 'prompt = no' 'x509_extensions = ext' \
        '[dn]' 'CN = ${identity}' \
        '[ext]' 'basicConstraints = critical,CA:false' 'keyUsage = critical,digitalSignature' \
        'extendedKeyUsage = critical,codeSigning' >"$cert/cert.cnf"
      /usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 36500 -config "$cert/cert.cnf" \
        -keyout "$cert/key.pem" -out "$cert/cert.pem" 2>/dev/null
      /usr/bin/openssl pkcs12 -export -inkey "$cert/key.pem" -in "$cert/cert.pem" \
        -name ${identity} -passout pass:${identity} -out "$cert/identity.p12"
      security import "$cert/identity.p12" -k ${keychain} -P ${identity} -T /usr/bin/codesign
      rm -rf "$cert"
    fi

    yabai_changed=
    if [ "$(cat ${stable}.source 2>/dev/null)" != "${pkgs.yabai}" ]; then
      echo "signing yabai at ${stable}..."
      mkdir -p "$(dirname ${stable})"
      cp ${yabai} ${stable}.new
      chmod u+w ${stable}.new
      /usr/bin/codesign -fs ${identity} --keychain ${keychain} -i com.koekeishiya.yabai ${stable}.new
      mv -f ${stable}.new ${stable}
      echo ${pkgs.yabai} >${stable}.source
      yabai_changed=1
    fi
  '';

  system.activationScripts.postActivation.text = ''
    if [ -n "$yabai_changed" ]; then
      launchctl kickstart -k "gui/$(id -u ${user})/org.nixos.yabai" 2>/dev/null || true
    fi
  '';
}
