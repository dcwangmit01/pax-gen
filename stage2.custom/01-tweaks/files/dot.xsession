# This is a startx script

# Start the window manager
matchbox-window-manager -use_titlebar no -use_cursor no &

# Start sound
start-pulseaudio-x11

# The mouse cursor is instead disabled by 'startx ./kiosk.sh -- -nocursor'
#   so the following is unnecessary
# unclutter &

# Remap touchscreen with 90 degree rotate
#   In conjunction with /boot/config.txt "display_rotate=1"
#   http://www.stuffaboutcode.com/2017/05/raspberry-pi-touchscreen-portrait.html
xinput --set-prop 'FT5406 memory based driver' 'Coordinate Transformation Matrix'  0 1 0 -1 0 1 0 0 1

# Disables power saving
# xset -dpms
# xset s off

# OS virtual keyboard
# matchbox-keyboard &

# Clear Chromium settings each time
rm -rf .cache/chromium .config/chromium

# Launch the browser
chromium-browser \
  --no-first-run \
  --disable-pinch \
  --allow-insecure-localhost \
  --incognito \
  --kiosk \
  'https://localhost'
#  'http://192.168.3.11:8080/config'

# Description of options used above
# --no-first-run  # disables the "You can search from here" dialog box
# --disable-pinch # disables pinch to zoom
# --allow-insecure-localhost # allows localhost self-signed certs
# --incognito # use incognito mode do not save defaults
# --kiosk # kiosk full-screen mode

# Chromium virtual keyboard options do not seem to work
#  --disable-usb-keyboard-detect \
#  --enable-virtual-keyboard  \
#  --enable-floating-virtual-keyboard \
