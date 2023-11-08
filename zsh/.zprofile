export PYENV_ROOT="$HOME/.pyenv"
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin/statusbar:$PATH"
export PATH="$HOME/.local/bin/appimages:$PATH"
export PATH="$HOME/android-studio/bin:$PATH"
export GUROBI_HOME="$HOME/gurobi951/linux64"
export PATH="${PATH}:${GUROBI_HOME}/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
export BROWSER="brave-browser"
export _JAVA_AWT_WM_NONREPARENTING=1
eval "$(rbenv init - )"
eval "$(pyenv init - )"
eval "$(pyenv init --path)"
eval $(thefuck --alias)
export EDITOR='lvim'
export VISUAL='lvim'

alias g="git"
alias v="lvim"
alias vim="lvim"
alias f="fuck"
alias tws="tmuxinator start tws"
alias budget="tmuxinator start budget"

if [ -e "./.zsecrets" ]; then
    source "./.zsecrets"
fi
