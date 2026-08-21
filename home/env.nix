{ ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "zeditor";
    RUSTC_WRAPPER = "sccache";

    GOPATH = "$HOME/.local/share/go";
    GOBIN = "$HOME/.local/bin";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.bun/bin"
  ];
}
