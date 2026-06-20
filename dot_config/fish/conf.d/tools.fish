if command -q zoxide
    zoxide init fish | source
end

if command -q atuin
    set -gx ATUIN_TMUX_POPUP false
    atuin init fish --disable-up-arrow | source
end

if command -q starship
    starship init fish | source
end

if test -f ~/.secret.fish
    source ~/.secret.fish
end

if test -f ~/.env.fish
    source ~/.env.fish
end
