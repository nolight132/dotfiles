if status is-interactive
    and not set -q TMUX
    and not set -q SSH_CONNECTION
    and not set -q SSH_CLIENT
    exec tmux
end
