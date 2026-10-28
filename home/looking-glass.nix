{ ... }:

{
  programs.looking-glass-client = {
    enable = true;

    settings = {
      # Right Ctrl, because the keyboard has no Scroll Lock and Right Alt types Polish letters.
      input.escapeKey = 97;

      spice.captureOnStart = true;
    };
  };
}
