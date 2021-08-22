# powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$HOME/bin:/usr/local/bin:$PATH # transition from bash
export ZSH="$HOME/.oh-my-zsh" # Path to your oh-my-zsh installation.
export EDITOR='nvim' # Set editor

# Files
source $ZSH/oh-my-zsh.sh

# Set name of the theme to load --- if set to "random", it will
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# Aliases
alias ls="colorls"
alias lc='colorls -lA --sd'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias ovim='\vim'
alias vrc='nvim ~/.config/nvim/init.vim'
alias zrc='nvim ~/.zshrc'
alias tws='tmuxinator start tws'



# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
