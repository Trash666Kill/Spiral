# Screen settings
#xrandr -s 1600x900 &
#xrandr --output HDMI-1 --auto --left-of eDP-1 &
#xrandr --output eDP-1 --scale 0.75x0.75 &
#xrandr --output DP-2 --rotate left &
#xrandr --output HDMI-2 --same-as HDMI-1 &
# Always on
xset -dpms &
xset s off &
#
numlockx &
nitrogen --restore &
lxpanel &
#virt-manager &
compton &