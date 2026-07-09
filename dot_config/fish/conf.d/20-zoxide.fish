if status is-interactive; and isatty stdout
    if command -sq zoxide
        zoxide init fish | source
    end
end

