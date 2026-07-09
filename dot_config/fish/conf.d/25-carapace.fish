if status is-interactive; and isatty stdout
    if command -sq carapace
        set -gx CARAPACE_LENIENT 1
        carapace _carapace fish | source
    end
end
