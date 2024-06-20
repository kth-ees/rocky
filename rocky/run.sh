# Set up SSH server
mkdir -p /var/run/sshd && \
ssh-keygen -A && \ 
echo 'root:password' | chpasswd && \
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Set up VNC server configuration
mkdir -p /root/.vnc && \
echo "password" | vncpasswd -f > /root/.vnc/passwd && \
chmod 600 /root/.vnc/passwd && \
dbus-uuidgen | tee /var/lib/dbus/machine-id && \
printf "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4 &" > /root/.vnc/xstartup && \
chmod +x /root/.vnc/xstartup

# start ssh and vnc
/usr/sbin/sshd
rm -rf /tmp/.X*
vncserver :1 -geometry 1280x1024 -depth 24
novnc_proxy --vnc localhost:5901 --listen 8080
tail -f /dev/null
