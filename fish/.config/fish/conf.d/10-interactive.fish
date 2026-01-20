if not status is-interactive
    return
end

zoxide init fish | source

if type -q pyenv
    pyenv init - | source
end

# Abbreviations
abbr -a code cd /home/nolight/Code/
abbr -a cow 'fortune -s -n 100 | cowsay'
abbr -a tux 'fortune -s -n 100 | cowsay -f tux'

# Aliases
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -a'

# Editor & Utils
abbr -a zed 'zeditor .'
abbr -a fetch fastfetch
abbr -a gvim nvim --listen /tmp/godothost
abbr -a linux 'docker run -it --rm -v "$PWD":/home/nolight/ linux-dev:latest'
