if status is-interactive
    function fish_user_key_bindings
        fish_vi_key_bindings
        bind -M insert \t accept-autosuggestion
        bind -M insert \e\[Z complete
        bind \cr _fish_search_history
    end
end
