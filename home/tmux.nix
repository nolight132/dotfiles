{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 1000000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      yank
      {
        plugin = resurrect;
        # This resurrect defaults to ~/.tmux/resurrect, but the saved history
        # lives under XDG. Pin it, or every restore looks in an empty dir and
        # silently comes up with nothing.
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.local/share/tmux/resurrect'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      fzf-tmux-url
      {
        plugin = tmux-sessionx;
        extraConfig = "set -g @sessionx-bind 'o'";
      }
      # NOTE: continuum is deliberately *not* listed here. See the bottom of
      # extraConfig for why it has to be loaded last.
    ];

    extraConfig = ''
      set -as terminal-features ",xterm-256color:RGB"

      set -g detach-on-destroy off
      set -g renumber-windows on
      set -g set-clipboard on
      set -g status-position top

      set -g status-interval 1
      set -g status-justify left
      set -g status-style bg=default

      set -g status-left-length 30
      set -g status-left "#{?client_prefix,#[fg=yellow]#[bold],#[fg=magenta,bold]} #S#[fg=default,nobold] "

      set -g status-right-length 100
      set -g status-right "#[fg=blue]  #(whoami) #[fg=white] #[fg=magenta] 󰒋 #(hostname)"

      set -g window-status-format "#[fg=brightblack] #W "
      set -g window-status-current-format "#[fg=magenta,bold] #W "
      set -g window-status-separator ""

      set -g pane-border-style "fg=brightblack,bg=default"
      set -g pane-active-border-style "fg=magenta,bg=default"

      bind ^X lock-server
      bind ^C new-window -c "$HOME"
      bind ^D detach
      bind * list-clients

      bind H previous-window
      bind L next-window

      bind r command-prompt "rename-window %%"
      bind ^A last-window
      bind ^W list-windows
      bind w list-windows
      bind z resize-pane -Z
      bind ^L refresh-client
      bind l refresh-client
      bind | split-window
      bind s split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind '"' choose-window
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r -T prefix , resize-pane -L 20
      bind -r -T prefix . resize-pane -R 20
      bind -r -T prefix - resize-pane -D 7
      bind -r -T prefix = resize-pane -U 7
      bind : command-prompt
      bind * setw synchronize-panes
      bind P set pane-border-status
      bind c kill-pane
      bind x swap-pane -D
      bind S choose-session
      bind R source-file ~/.config/tmux/tmux.conf
      bind K send-keys "clear"\; send-keys "Enter"
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-h previous-window
      bind -n M-l next-window

      set -g status-bg default
      set -g status-style bg=default
      set -g window-style 'bg=default'
      set -g window-active-style 'bg=default'

      # tmux-continuum must be sourced *after* status-right is set. Its only
      # auto-save timer is a #(continuum_save.sh) interpolation it prepends to
      # the status line, so any later `set -g status-right` silently wipes it
      # out and nothing is ever saved. home-manager emits plugin run-shell
      # lines before extraConfig, so it is loaded by hand here instead.
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '5'
      run-shell ${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
    '';
  };
}
