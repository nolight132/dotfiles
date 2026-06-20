function fish_user_key_bindings
    # - Tab accepts gray history suggestion if present, else opens completions.
    # - Shift-Tab always opens completions.
    bind \t __nu_tab
    bind -M insert \t __nu_tab
    bind -M visual \t __nu_tab
    bind -M replace \t __nu_tab

    bind shift-tab __nu_shift_tab
    bind -M insert shift-tab __nu_shift_tab
    bind -M visual shift-tab __nu_shift_tab
    bind -M replace shift-tab __nu_shift_tab
    bind \e\[Z __nu_shift_tab
    bind -M insert \e\[Z __nu_shift_tab
    bind -M visual \e\[Z __nu_shift_tab
    bind -M replace \e\[Z __nu_shift_tab
end
