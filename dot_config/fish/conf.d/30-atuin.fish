if status is-interactive
    if command -sq atuin
        atuin init fish --disable-up-arrow | source
    end
end

