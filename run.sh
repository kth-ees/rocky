#mkdir /run/dbus
#dbus-daemon --system &
#rm -f /run/nologin 
/usr/sbin/sshd
rm -rf /tmp/.X*
vncserver :1 -geometry 1280x1024 -depth 24
novnc_proxy --vnc localhost:5901 --listen 8080
tail -f /dev/null
