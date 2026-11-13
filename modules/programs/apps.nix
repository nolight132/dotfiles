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

  # Vencord 1.15.13 cannot patch the rspack bundle Discord ships since November 2026,
  # so the client hangs on "Starting...". 1.15.16 fixes it and drops the deps patch.
  # TODO: drop this override once nixos-unstable ships vencord 1.15.16 or newer.
  vencord = pkgs.vencord.overrideAttrs (
    finalAttrs: old: {
      version = "1.15.16";
      src = pkgs.fetchFromGitHub {
        owner = "Vendicated";
        repo = "Vencord";
        tag = "v${finalAttrs.version}";
        hash = "sha256-aUJubLJpyLAZWiOezqFxPY6oVPgWVPQpajFqrJvrO9U=";
      };
      patches = [ ];
      postPatch = "";
      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = pkgs.pnpm_11;
        fetcherVersion = 4;
        hash = "sha256-HS8uZNepvDefjrsG3buVLFCVv7sHvazcwdpcT3EQ/78=";
      };
    }
  );
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
      (pkgs.discord.override {
        withVencord = true;
        inherit vencord;
      })
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
