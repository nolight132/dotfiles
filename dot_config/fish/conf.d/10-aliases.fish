alias cat='bat'
alias ls='nls'

switch (uname -s)
    case Darwin
        alias zed='zed .'
    case '*'
        alias zed='zeditor .'
        alias files='kioclient5 exec .'
end
