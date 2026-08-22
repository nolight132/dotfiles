{ ... }:

{
  programs.zoxide.enable = true;
  programs.carapace.enable = true;

  home.sessionVariables.CARAPACE_LENIENT = "1";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.log_filter = "^$";
  };
}
