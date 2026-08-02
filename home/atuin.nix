{ ... }:

{
  programs.atuin = {
    enable = true;
    daemon.enable = true;

    flags = [ "--disable-up-arrow" ];

    settings = {
      enter_accept = true;
      search_mode = "daemon-fuzzy";
      sync.records = true;
      ai.enabled = true;
    };
  };
}
