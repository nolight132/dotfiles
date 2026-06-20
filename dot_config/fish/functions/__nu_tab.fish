function __nu_tab --description "Nu-like Tab: accept history suggestion else show completions"
    if commandline --showing-suggestion
        commandline -f accept-autosuggestion
    else
        __nu_complete_menu
    end
end
