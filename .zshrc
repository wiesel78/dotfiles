[[ -f ~/.config/zsh/path.zsh ]] && source ~/.config/zsh/path.zsh
[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh
[[ -f ~/.config/zsh/functions.zsh ]] && source ~/.config/zsh/functions.zsh
[[ -f ~/.config/zsh/starship.zsh ]] && source ~/.config/zsh/starship.zsh
[[ -f ~/.config/zsh/wsl2fix.zsh ]] && source ~/.config/zsh/wsl2fix.zsh
[[ -f ~/.config/zsh/goto.zsh ]] && source ~/.config/zsh/goto.zsh
[[ -f ~/.config/zsh/fzf.zsh ]] && source ~/.config/zsh/fzf.zsh
[[ -f ~/.config/zsh/completion.zsh ]] && source ~/.config/zsh/completion.zsh

# Load colors (for exa)
export LS_COLORS="$(vivid generate molokai)"
export EXA_COLORS="da=32"

# Set default editor
EDITOR='nvim'

# set vi mode
set -o vi
KEYTIMEOUT=1


# Load Starship
prompt off

# load tmuxifier if tmuxifier is available
if command -v tmuxifier &> /dev/null; then
  eval "$(tmuxifier init -)"
fi

# Load Starship if starship is available
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

