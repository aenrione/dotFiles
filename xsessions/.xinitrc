#source /home/aenrione/.zshrc
[ -f ~/.xprofile ] && . ~/.xprofile
[ -f ~/.config/shell/exports ] && . ~/.config/shell/exports
~/.screenlayout/screen-select.sh
~/.fehbg
nohup battery_loop.sh > /dev/null 2>&1 &
exec /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
remaps
exec dwm
