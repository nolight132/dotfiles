if status is-interactive
    fish_vi_key_bindings
    if functions -q fish_user_key_bindings
        fish_user_key_bindings
    end

    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_replace_one line
    set -g fish_cursor_visual block
end
