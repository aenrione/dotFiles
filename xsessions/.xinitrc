#source /home/aenrione/.zshrc
[ -f ~/.xprofile ] && . ~/.xprofile
[ -f ~/.config/shell/exports ] && . ~/.config/shell/exports
~/.screenlayout/screen-select.sh
nohup battery_loop.sh > /dev/null 2>&1 &
remaps
exec dwm
