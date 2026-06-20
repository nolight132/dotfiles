if status is-interactive
    if command -sq zoxide
        zoxide init fish | source
    end
end

