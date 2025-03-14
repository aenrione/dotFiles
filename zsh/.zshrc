# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.zsh_history
#
# Brew
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/exports" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/exports"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/source" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/source"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/evals" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/evals"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/cli-tools" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/cli-tools"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/secrets" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/secrets"


# pnpm
export PNPM_HOME="/home/aenrione/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

if [ -e /home/aenrione/.nix-profile/etc/profile.d/nix.sh ]; then . /home/aenrione/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
