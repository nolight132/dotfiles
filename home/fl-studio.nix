{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Staging carries the newest Wine fixes for FL Studio's menus and plugin windows. The prefix is kept apart
  # from ~/.wine, because yabridge pins Wine 9.21 there and a newer Wine would upgrade that prefix under it.
  wine = pkgs.wineWow64Packages.stagingFull;
  prefix = "${config.xdg.dataHome}/wineprefixes/fl-studio";
  flDir = "${prefix}/drive_c/Program Files/Image-Line/FL Studio 2026";
  iconPath = "${config.xdg.dataHome}/icons/hicolor/256x256/apps/fl-studio.png";

  themeColors = "${config.xdg.cacheHome}/fl-studio/noctalia.colors";

  # WineASIO opens 16 channels each way by default and wires the extras into every other card, HDMI
  # included. One stereo pair covers the master bus and the MiniFuse's input.
  wineasioChannels = 2;

  # JUCE 8 plugins such as Surge XT draw through Direct2D, and on Wine's own D3D11 their editors stop
  # repainting after the first frame. DXVK fixes that, but it has no composition swapchains, so WebView2,
  # which renders FL Studio's sound browser, keeps Wine's builtin D3D.
  dxvkDlls = [
    "d3d8"
    "d3d9"
    "d3d10core"
    "d3d11"
    "dxgi"
  ];

  dllOverrides = mode: lib.concatMapStrings (dll: "\"${dll}\"=\"${mode}\"\n") dxvkDlls;
  dword = n: lib.toLower (lib.fixedWidthString 8 "0" (lib.toHexString n));

  prefixRegistry = pkgs.writeText "fl-studio-prefix.reg" ''
    REGEDIT4

    [HKEY_CURRENT_USER\Software\Wine\WineASIO]
    "Number of inputs"=dword:${dword wineasioChannels}
    "Number of outputs"=dword:${dword wineasioChannels}

    [HKEY_CURRENT_USER\Software\Wine\DllOverrides]
    ${dllOverrides "native"}
    [HKEY_CURRENT_USER\Software\Wine\AppDefaults\msedgewebview2.exe\DllOverrides]
    ${dllOverrides "builtin"}
  '';

  # WineASIO is an ELF builtin whose fake PE names itself wineasio.dll, so Wine looks for wineasio.dll.so and
  # never finds the wineasio64 files nixpkgs installs. These links give it both names.
  wineasio = pkgs.runCommand "wineasio-dlls" { } ''
    mkdir -p $out/x86_64-unix $out/x86_64-windows
    for dir in x86_64-unix x86_64-windows; do
      ln -s ${pkgs.wineasio}/lib/wine/$dir/* $out/$dir/
    done
    ln -s ${pkgs.wineasio}/lib/wine/x86_64-unix/wineasio64.dll.so $out/x86_64-unix/wineasio.dll.so
    ln -s ${pkgs.wineasio}/lib/wine/x86_64-windows/wineasio64.dll $out/x86_64-windows/wineasio.dll
  '';

  # WineASIO talks to JACK through PipeWire's libjack, and its PE and Unix halves are found through WINEDLLPATH.
  # winemenubuilder stays off so installers do not leave desktop entries that point at a stale Wine.
  wineEnv = ''
    export WINEPREFIX="${prefix}"
    mkdir -p "$WINEPREFIX"
    export WINEDLLPATH="${wineasio}"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d''${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"
    export WINEDEBUG="''${WINEDEBUG:--all}"
    export LD_LIBRARY_PATH="${pkgs.pipewire.jack}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export PIPEWIRE_LATENCY="''${PIPEWIRE_LATENCY:-128/48000}"
    export PATH="${
      lib.makeBinPath [
        wine
        pkgs.winetricks
      ]
    }:$PATH"
  '';

  # Runs any Wine command inside the FL Studio prefix, such as a plugin installer, winecfg or winetricks.
  flWine = pkgs.writeShellScriptBin "fl-wine" ''
    ${wineEnv}
    exec "$@"
  '';

  # Prints the Wine DPI and the Wine desktop size in physical pixels for the output niri has focused, so FL
  # Studio follows that monitor's scale. It falls back to a 2560x1440 monitor at scale 1.25 when niri is not running.
  outputGeometry = pkgs.writeShellScript "fl-studio-output" ''
    geometry="$(niri msg --json focused-output 2> /dev/null \
      | ${lib.getExe pkgs.jq} -r '.logical | [96 * .scale, .width * .scale, .height * .scale] | map(round) | "\(.[0]) \(.[1])x\(.[2])"' 2> /dev/null)"
    echo "''${geometry:-120 2560x1440}"
  '';

  # FL Studio drags its captionless dialogs by moving them under the cursor, and xwayland-satellite places
  # moved X windows at the wrong scale, so they fly off. Inside a Wine desktop the moves never reach X.
  # Project paths are handed over as Windows paths, since FL Studio would read a Unix path as one on drive C.
  # The DPI is written on every launch, because Wine reads it only when a process starts.
  flStudio = pkgs.writeShellScriptBin "fl-studio" ''
    ${wineEnv}
    read -r dpi desktopSize < <(${outputGeometry})
    wine reg add 'HKCU\Control Panel\Desktop' /v LogPixels /t REG_DWORD /d "$dpi" /f > /dev/null
    args=()
    for arg in "$@"; do
      if [ -e "$arg" ]; then
        arg="$(wine winepath -w "$arg")"
      fi
      args+=("$arg")
    done
    exec wine explorer /desktop=fl-studio,$desktopSize "C:\Program Files\Image-Line\FL Studio 2026\FL64.exe" "''${args[@]}"
  '';

  # Writes the palette Noctalia rendered into FL Studio's preset list and into the theme it loads at startup.
  # FL Studio saves its live theme over the startup one on exit, so a palette change made while it runs
  # takes effect by picking the Noctalia preset in its theme settings.
  flTheme = pkgs.writeShellScriptBin "fl-studio-theme" ''
    set -eu
    colors="${themeColors}"
    themes="${config.xdg.userDirs.documents}/Image-Line/FL Studio/Settings/Themes"
    [ -f "$colors" ] && [ -d "$themes" ] || exit 0
    ${lib.getExe pkgs.gawk} -f ${./fl-studio/theme.awk} "$colors" > "$themes/Noctalia.flstheme"
    cp "$themes/Noctalia.flstheme" "$themes/__current.flstheme"
  '';

  # The launcher icon is taken from FL64.exe, so it follows whatever version is installed.
  flIcon = pkgs.writeShellScript "fl-studio-icon" ''
    ico="$(mktemp)"
    trap 'rm -f "$ico"' EXIT
    mkdir -p "$(dirname "${iconPath}")"
    ${pkgs.icoutils}/bin/wrestool -x -t 14 "${flDir}/FL64.exe" > "$ico"
    ${pkgs.icoutils}/bin/icotool -x -w 256 -o "${iconPath}" "$ico"
  '';
in
{
  home.packages = [
    flStudio
    flWine
    flTheme
  ];

  xdg.desktopEntries.fl-studio = {
    name = "FL Studio";
    genericName = "Digital Audio Workstation";
    exec = "fl-studio %f";
    icon = "fl-studio";
    categories = [
      "AudioVideo"
      "Audio"
    ];
    mimeType = [ "application/x-flp" ];
  };

  # The prefix and FL Studio itself are installed by hand. Once they exist, every switch puts DXVK, WineASIO,
  # the registry settings and the icon back in place, which is safe while FL Studio is running.
  home.activation.flStudioPrefix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${prefix}/drive_c/windows" ]; then
      for dll in ${lib.concatStringsSep " " dxvkDlls}; do
        run install -m644 "${pkgs.dxvk.bin}/x64/$dll.dll" "${prefix}/drive_c/windows/system32/$dll.dll"
        run install -m644 "${pkgs.dxvk.bin}/x32/$dll.dll" "${prefix}/drive_c/windows/syswow64/$dll.dll"
      done
      run ${lib.getExe flWine} wine regsvr32 /s wineasio64.dll
      run ${lib.getExe flWine} wine regedit /S ${prefixRegistry}
    fi
    if [ -f "${flDir}/FL64.exe" ]; then
      run ${flIcon}
    fi
    run ${lib.getExe flTheme}
  '';
}
