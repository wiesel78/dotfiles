[[ -f ~/.config/zsh/path.zsh ]] && source ~/.config/zsh/path.zsh
[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh
[[ -f ~/.config/zsh/functions.zsh ]] && source ~/.config/zsh/functions.zsh
[[ -f ~/.config/zsh/starship.zsh ]] && source ~/.config/zsh/starship.zsh
[[ -f ~/.config/zsh/wsl2fix.zsh ]] && source ~/.config/zsh/wsl2fix.zsh
[[ -f ~/.config/zsh/goto.zsh ]] && source ~/.config/zsh/goto.zsh
[[ -f ~/.config/zsh/fzf.zsh ]] && source ~/.config/zsh/fzf.zsh

# Load colors (for exa)
export LS_COLORS="$(vivid generate molokai)"
export EXA_COLORS="da=32"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=1000
setopt SHARE_HISTORY

bindkey -v
bindkey '^R' history-incremental-search-backward

# Load Starship
eval "$(starship init zsh)"
