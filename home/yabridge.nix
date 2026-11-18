{
  config,
  lib,
  pkgs,
  ...
}:

let
  winePrefix = "${config.home.homeDirectory}/.wine";
  commonFiles = "${winePrefix}/drive_c/Program Files/Common Files";

  # Matches the 1.25 output scale in niri, so Windows plugins draw at the size of the rest of the desktop.
  wineDpi = 120;

  # JUCE 8 plugins draw through Direct2D on top of D3D11, and on Wine's own D3D11 their editor hangs after a
  # few seconds. DXVK replaces the D3D and DXGI libraries in the prefix with its Vulkan implementation.
  dxvkDlls = [
    "d3d8"
    "d3d9"
    "d3d10core"
    "d3d11"
    "dxgi"
  ];

  prefixRegistry = pkgs.writeText "wine-prefix.reg" ''
    REGEDIT4

    [HKEY_CURRENT_USER\Control Panel\Desktop]
    "LogPixels"=dword:${lib.toLower (lib.fixedWidthString 8 "0" (lib.toHexString wineDpi))}

    [HKEY_CURRENT_USER\Software\Wine\DllOverrides]
    ${lib.concatMapStrings (dll: "\"${dll}\"=\"native\"\n") dxvkDlls}
  '';

  # yabridgectl rewrites its config on every sync, so it is installed as a plain file instead of a store symlink.
  yabridgectlConfig = (pkgs.formats.toml { }).generate "yabridgectl-config.toml" {
    plugin_dirs = [
      "${commonFiles}/CLAP"
      "${commonFiles}/VST3"
      "${winePrefix}/drive_c/Program Files/Steinberg/VstPlugins"
    ];
    vst2_location = "centralized";
    no_verify = false;
    blacklist = [ ];
  };
in
{
  # REAPER passes its UI scale to VST3 editors, and Windows plugins answer by resizing themselves back and
  # forth against Wine's DPI. They take their scale from Wine's DPI alone instead.
  home.file.".vst3/yabridge/yabridge.toml".source = (pkgs.formats.toml { }).generate "yabridge.toml" {
    "*.vst3".editor_disable_host_scaling = true;
  };

  home.activation.yabridgectlConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${yabridgectlConfig} "${config.xdg.configHome}/yabridgectl/config.toml"
  '';

  # The prefix is mutable, so DXVK and the registry settings are written into it on every switch once it exists.
  home.activation.winePrefix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${winePrefix}/drive_c/windows" ]; then
      for dll in ${lib.concatStringsSep " " dxvkDlls}; do
        run install -m644 "${pkgs.dxvk.bin}/x64/$dll.dll" "${winePrefix}/drive_c/windows/system32/$dll.dll"
        run install -m644 "${pkgs.dxvk.bin}/x32/$dll.dll" "${winePrefix}/drive_c/windows/syswow64/$dll.dll"
      done
      WINEPREFIX="${winePrefix}" WINEDEBUG=-all run ${pkgs.wineWow64Packages.yabridge}/bin/wine regedit /S ${prefixRegistry}
    fi
  '';
}
