# Start the X server that can run on machines with no display 
# hardware and no physical input devices
/etc/init.d/xvfb Start
sleep 0.5


/etc/init.d/selenium Start
sleep 0.5
