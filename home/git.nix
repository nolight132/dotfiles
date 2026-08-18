{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nolight132";
        email = "contact@nolight.dev";
      };

      push.default = "current";
      remote.pushDefault = "origin";

      credential = {
        helper = [
          ""
          "store"
        ];
        "https://github.com".helper = "!gh auth git-credential";
      };
    };
  };
}
