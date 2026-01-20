set -g __done_min_cmd_duration 5000
if status is-interactive
    set -g fish_tmux_fixterm false
    set -g fish_tmux_autostart true
    set -g fish_greeting ""
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
