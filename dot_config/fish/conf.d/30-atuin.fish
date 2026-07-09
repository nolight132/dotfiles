if status is-interactive; and isatty stdout
    if command -sq atuin
        atuin init fish --disable-up-arrow | source
    end
end

