# Paths

# Homebrew
if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# SDKs & Variables
set -gx TERM xterm-256color
