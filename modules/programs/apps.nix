{
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  # patchelf 0.18 and 0.19 move .dynamic of the REAPER binary into its read-only
  # text segment, so ld.so segfaults on startup. 0.15.2 keeps the segments apart.
  # TODO: drop this override once nixpkgs ships a patchelf that patches REAPER correctly.
  reaper = pkgs.reaper.overrideAttrs (old: {
    nativeBuildInputs = [
      (pkgs.patchelf.overrideAttrs {
        version = "0.15.2";
        src = pkgs.fetchurl {
          url = "https://github.com/NixOS/patchelf/releases/download/0.15.2/patchelf-0.15.2.tar.bz2";
          hash = "sha256-F3RfVkFZyOIo/EEtplogSLhGxLa0Igt3y/IkFuAvLXw=";
        };
      })
    ]
    ++ old.nativeBuildInputs;
  });
in
{
  environment.systemPackages = (
    with pkgs;
    [
      # System
      nautilus
      clapper
      file-roller
      libreoffice
      ffmpegthumbnailer
      tumbler
      evince
      sushi
      video-trimmer
      loupe
      kdePackages.filelight

      # Browsers
      inputs.helium.packages.${system}.default
      (pkgs.symlinkJoin {
        name = "zen-browser";
        paths = [ inputs.zen-browser.packages.${system}.default ];

        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/zen \
            --set MOZ_GTK_TITLEBAR_DECORATION none
        '';
      })

      # Development
      bruno
      godot

      # Communication
      telegram-desktop
      vesktop
      (pkgs.discord.override { withVencord = true; })
      element-desktop

      # Music
      reaper
      ratatouille-lv2
      neural-amp-modeler-lv2
      calf
      guitarix-vst
      spotify
      inputs.sonora.packages.${system}.default

      # Gaming
      osu-lazer-bin
      prismlauncher
      vinegar

      # Misc
      obs-studio
      krita
      aseprite
      inputs.photocraft.packages.${system}.default
      qbittorrent
      proton-vpn
      mangohud
      openjdk25

      # Uni bullshit (doesn't even fucking work)
      # cisco-packet-tracer_9
    ]
  );
}
