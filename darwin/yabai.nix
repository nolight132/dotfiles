{ ... }:

{
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    extraConfig = ''
      yabai -m config layout float
      yabai -m config mouse_follows_focus off
      yabai -m config focus_follows_mouse off
    '';
  };
}
