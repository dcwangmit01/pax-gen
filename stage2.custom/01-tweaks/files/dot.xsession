# This is a script run by startx

# Start the window manager
matchbox-window-manager -use_titlebar no -use_cursor no &

# Start sound
start-pulseaudio-x11

# The mouse cursor is instead disabled by 'startx ./kiosk.sh -- -nocursor'
# unclutter &

# Remap touchscreen with 90 degree rotate
#   In conjunction with /boot/config.txt "display_rotate=1"
#   http://www.stuffaboutcode.com/2017/05/raspberry-pi-touchscreen-portrait.html
xinput --set-prop 'FT5406 memory based driver' 'Coordinate Transformation Matrix'  0 1 0 -1 0 1 0 0 1

# Disable power saving
# xset -dpms
# xset s off

# Clear cache and config for the web browser
rm -rf .cache/chromium .config/chromium
chromium-browser 'http://192.168.3.11:5000' --disable-pinch # --kiosk

# --disable-session-crashed-bubble --disable-infobars --incognito

#while true; do
#  rm -rf ~/.{config,cache}/google-chrome/
#  google-chrome --kiosk --no-first-run  'http://thepcspy.com'
#done

# https://thepcspy.com/read/building-a-kiosk-computer-ubuntu-1404-chrome/
