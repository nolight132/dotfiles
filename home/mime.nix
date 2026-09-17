{ lib, ... }:

let
  browser = "zen.desktop";
  fileManager = "org.gnome.Nautilus.desktop";
  imageViewer = "org.gnome.Loupe.desktop";
  mediaPlayer = "com.github.rafostar.Clapper.desktop";
  documentViewer = "org.gnome.Evince.desktop";
  archiver = "org.gnome.FileRoller.desktop";
  editor = "dev.zed.Zed.desktop";
  torrentClient = "org.qbittorrent.qBittorrent.desktop";

  imageTypes = [
    "image/apng"
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heic"
    "image/jp2"
    "image/jpeg"
    "image/jxl"
    "image/png"
    "image/qoi"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/tiff"
    "image/vnd.microsoft.icon"
    "image/webp"
    "image/x-dds"
    "image/x-exr"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-qoi"
    "image/x-tga"
    "image/x-win-bitmap"
    "image/x-xbitmap"
    "image/x-xpixmap"
  ];

  videoTypes = [
    "video/3gpp"
    "video/3gpp2"
    "video/dv"
    "video/mp2t"
    "video/mp4"
    "video/mpeg"
    "video/ogg"
    "video/quicktime"
    "video/webm"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-ms-wmv"
    "video/x-msvideo"
    "video/x-ogm+ogg"
    "video/x-theora+ogg"
    "application/vnd.apple.mpegurl"
    "application/x-matroska"
  ];

  audioTypes = [
    "audio/aac"
    "audio/ac3"
    "audio/flac"
    "audio/midi"
    "audio/mp4"
    "audio/mpeg"
    "audio/mpegurl"
    "audio/ogg"
    "audio/opus"
    "audio/wav"
    "audio/webm"
    "audio/x-aiff"
    "audio/x-ape"
    "audio/x-flac"
    "audio/x-m4a"
    "audio/x-matroska"
    "audio/x-mpegurl"
    "audio/x-ms-wma"
    "audio/x-musepack"
    "audio/x-vorbis+ogg"
    "audio/x-wav"
    "audio/x-wavpack"
  ];

  documentTypes = [
    "application/pdf"
    "application/x-bzpdf"
    "application/x-gzpdf"
    "application/x-xzpdf"
    "application/postscript"
    "application/x-dvi"
    "application/oxps"
    "application/vnd.ms-xpsdocument"
    "application/illustrator"
    "application/vnd.comicbook-rar"
    "application/vnd.comicbook+zip"
    "application/x-cb7"
    "application/x-cbr"
    "application/x-cbt"
    "application/x-cbz"
    "image/vnd.djvu"
    "image/x-eps"
  ];

  archiveTypes = [
    "application/bzip2"
    "application/gzip"
    "application/vnd.debian.binary-package"
    "application/vnd.ms-cab-compressed"
    "application/vnd.rar"
    "application/x-7z-compressed"
    "application/x-7z-compressed-tar"
    "application/x-apple-diskimage"
    "application/x-ar"
    "application/x-archive"
    "application/x-bzip"
    "application/x-bzip-compressed-tar"
    "application/x-bzip2-compressed-tar"
    "application/x-cd-image"
    "application/x-compress"
    "application/x-compressed-tar"
    "application/x-cpio"
    "application/x-gtar"
    "application/x-gzip"
    "application/x-java-archive"
    "application/x-lha"
    "application/x-lz4"
    "application/x-lz4-compressed-tar"
    "application/x-lzip"
    "application/x-lzip-compressed-tar"
    "application/x-lzma"
    "application/x-lzma-compressed-tar"
    "application/x-lzop"
    "application/x-rar"
    "application/x-rar-compressed"
    "application/x-rpm"
    "application/x-tar"
    "application/x-tarz"
    "application/x-xar"
    "application/x-xz"
    "application/x-xz-compressed-tar"
    "application/x-zip"
    "application/x-zip-compressed"
    "application/x-zstd-compressed-tar"
    "application/zip"
    "application/zstd"
  ];

  textTypes = [
    "text/plain"
    "text/markdown"
    "text/x-markdown"
    "text/csv"
    "text/tab-separated-values"
    "text/xml"
    "text/x-log"
    "text/x-readme"
    "text/x-makefile"
    "text/x-cmake"
    "text/x-shellscript"
    "text/x-script.python"
    "text/x-python"
    "text/x-python3"
    "text/x-rust"
    "text/x-go"
    "text/x-c"
    "text/x-csrc"
    "text/x-chdr"
    "text/x-c++"
    "text/x-c++src"
    "text/x-c++hdr"
    "text/x-java"
    "text/x-lua"
    "text/x-nix"
    "text/x-sql"
    "text/x-tex"
    "text/x-toml"
    "text/x-yaml"
    "text/x-patch"
    "text/x-diff"
    "text/javascript"
    "text/typescript"
    "text/css"
    "application/json"
    "application/ld+json"
    "application/x-yaml"
    "application/yaml"
    "application/toml"
    "application/xml"
    "application/x-shellscript"
    "application/x-nix"
    "application/javascript"
    "application/x-javascript"
    "application/typescript"
    "application/x-zerosize"
  ];

  openWith = types: app: lib.genAttrs types (_: [ app ]);
in
{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "inode/directory" = [ fileManager ];

      "text/html" = [ browser ];
      "application/xhtml+xml" = [ browser ];
      "x-scheme-handler/http" = [ browser ];
      "x-scheme-handler/https" = [ browser ];
      "x-scheme-handler/about" = [ browser ];
      "x-scheme-handler/unknown" = [ browser ];

      "x-scheme-handler/magnet" = [ torrentClient ];
      "application/x-bittorrent" = [ torrentClient ];

      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/discord" = [ "vesktop.desktop" ];
      "x-scheme-handler/element" = [ "element-desktop.desktop" ];
      "x-scheme-handler/io.element.desktop" = [ "element-desktop.desktop" ];
      "x-scheme-handler/spotify" = [ "spotify.desktop" ];
      "x-scheme-handler/zed" = [ editor ];
      "x-scheme-handler/terminal" = [ "com.mitchellh.ghostty.desktop" ];

      "x-scheme-handler/curseforge" = [ "org.prismlauncher.PrismLauncher.desktop" ];
      "x-scheme-handler/prismlauncher" = [ "org.prismlauncher.PrismLauncher.desktop" ];
      "application/x-modrinth-modpack+zip" = [ "org.prismlauncher.PrismLauncher.desktop" ];

      "application/x-krita" = [ "org.kde.krita.desktop" ];
      "image/openraster" = [ "org.kde.krita.desktop" ];
      "image/x-psd" = [ "org.kde.krita.desktop" ];
      "image/vnd.adobe.photoshop" = [ "org.kde.krita.desktop" ];
      "image/x-xcf" = [ "org.kde.krita.desktop" ];

      "application/x-reaper-project" = [ "cockos-reaper.desktop" ];
      "application/vnd.mlt+xml" = [ "org.shotcut.Shotcut.desktop" ];
    }
    // openWith imageTypes imageViewer
    // openWith videoTypes mediaPlayer
    // openWith audioTypes mediaPlayer
    // openWith documentTypes documentViewer
    // openWith archiveTypes archiver
    // openWith textTypes editor;
  };
}
