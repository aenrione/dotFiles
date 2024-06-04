#source /home/aenrione/.zshrc
[ -f ~/.xprofile ] && . ~/.xprofile
## ~/.xinitrc or ~/.xprofile or ~/.xsession
# [ -f ~/.zshrc ] && . ~/.zshrc 2> ~/.zshrc_errors.log
~/.screenlayout/screen-select.sh
nohup battery_loop.sh > /dev/null 2>&1 &
remaps
exec dwm
sh /opt/scripts/battery-status-1.sh &
