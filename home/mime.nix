{ ... }:

{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = [ "zen.desktop" ];
      "x-scheme-handler/http" = [ "zen.desktop" ];
      "x-scheme-handler/https" = [ "zen.desktop" ];
    };
  };
}
