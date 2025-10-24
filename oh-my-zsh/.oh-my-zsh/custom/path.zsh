export PATH=$PATH:/Users/pavelolizko/Android_Tools/platform-tools/
export PATH=~/flutter/flutter/bin:$PATH
export PATH=$PATH:/Users/pavelolizko/.spicetify
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# bun completions
[ -s "/Users/pavelolizko/.bun/_bun" ] && source "/Users/pavelolizko/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PNPM_HOME="/Users/pavelolizko/Library/pnpm"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# node
export NVM_DIR="$HOME/.nvm"
 [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
 [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
