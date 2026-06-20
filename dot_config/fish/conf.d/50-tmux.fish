if status is-interactive
    if command -sq tmux
        if not set -q TMUX
            if not set -q SSH_CONNECTION; and not set -q SSH_CLIENT
                exec tmux
            end
        end
    end
end

