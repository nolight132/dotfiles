bindkey -v
autoload -U compinit
compinit
touch ~/.hushlogin
source /Users/pavelolizko/.oh-my-zsh/custom/plugins/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^I' autosuggest-accept
