#mkdir /run/dbus
#dbus-daemon --system &
#rm -f /run/nologin 
/usr/sbin/sshd
rm -rf /tmp/.X*
vncserver :1 -geometry 1280x1024 -depth 24
tail -f /dev/null
