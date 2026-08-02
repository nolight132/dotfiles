{ ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "bat";
      ls = "nls";
      zed = "zeditor .";
      files = "nautilus .";
    };

    functions = {
      nrs = ''
        	switch $hostname
         		case macbook
           		set config laptop
            case zapc
            	set config desktop
          end

          sudo nixos-rebuild switch --flake ~/Dotfiles#$config $argv
          or return

          systemctl --user restart vicinae.service
      '';

      claudex = ''
        env \
            ANTHROPIC_BASE_URL=http://127.0.0.1:8317 \
            ANTHROPIC_AUTH_TOKEN=$CLAUDEX_TOKEN \
            ENABLE_CLAUDEAI_MCP_SERVERS=false \
            CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol \
            CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 \
            CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 \
            ENABLE_TOOL_SEARCH=false \
            claude --model gpt-5.6-sol $argv
      '';

      __nu_tab = {
        description = "Nu-like Tab: accept history suggestion else show completions";
        body = ''
          if commandline --showing-suggestion
              commandline -f accept-autosuggestion
          else
              __nu_complete_menu
          end
        '';
      };

      __nu_shift_tab = {
        description = "Nu-like Shift-Tab: show full completion list";
        body = "__nu_complete_menu";
      };

      fish_user_key_bindings = ''
        bind \t __nu_tab
        bind -M insert \t __nu_tab
        bind -M visual \t __nu_tab
        bind -M replace \t __nu_tab

        bind shift-tab __nu_shift_tab
        bind -M insert shift-tab __nu_shift_tab
        bind -M visual shift-tab __nu_shift_tab
        bind -M replace shift-tab __nu_shift_tab
        bind \e\[Z __nu_shift_tab
        bind -M insert \e\[Z __nu_shift_tab
        bind -M visual \e\[Z __nu_shift_tab
        bind -M replace \e\[Z __nu_shift_tab
      '';
    };

    interactiveShellInit = ''
      set -g fish_greeting ""

      if isatty stdout
          fish_vi_key_bindings
          fish_user_key_bindings

          set -g fish_cursor_default block
          set -g fish_cursor_insert line
          set -g fish_cursor_replace_one line
          set -g fish_cursor_visual block
      end

      set -g fish_pager_color_background normal
      set -g fish_pager_color_completion cdd6f4
      set -g fish_pager_color_description f9e2af
      set -g fish_pager_color_prefix --bold cdd6f4
      set -g fish_pager_color_progress 6c7086
      set -g fish_pager_color_secondary 7f849c
      set -g fish_pager_color_secondary_background normal
      set -g fish_pager_color_selected_background --background=585b70
      set -g fish_pager_color_selected_completion --bold f5f5f5
      set -g fish_pager_color_selected_description --bold f5f5f5

      set -g fish_color_autosuggestion 6c7086

      for f in $HOME/.secret.fish $HOME/.env.fish $HOME/.config/fish/local.fish
          if test -f $f
              source $f
          end
      end
    '';

    shellInitLast = ''
      if status is-interactive; and isatty stdout
        if command -sq tmux; and not set -q TMUX
          if not set -q SSH_CONNECTION; and not set -q SSH_CLIENT
            if command tmux has-session 2>/dev/null
              exec tmux attach-session
            else
              exec tmux new-session -s term
            end
          end
        end
      end
    '';
  };

  xdg.configFile."fish/functions/__nu_complete_menu.fish".source = ./fish/__nu_complete_menu.fish;
}
