{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      profile-sync-daemon = prev.profile-sync-daemon.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          cp $out/share/psd/browsers/firefox \
            $out/share/psd/browsers/zen

          substituteInPlace $out/share/psd/browsers/zen \
            --replace-fail ".mozilla/firefox" ".config/zen"
        '';
      });
    })
  ];

  services.psd = {
    enable = true;
    resyncTimer = "10m";
  };
}
