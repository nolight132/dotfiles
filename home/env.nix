{ ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "zeditor";
    RUSTC_WRAPPER = "sccache";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.bun/bin"
    "$HOME/.local/share/go/bin"
  ];
}
