if status is-interactive; and isatty stdout
    if command -sq starship
        starship init fish | source
    end
end

