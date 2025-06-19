# Set up SSH server
mkdir -p /var/run/sshd
# ssh-keygen -A
echo 'root:3CEPnGrebYcHGnbHiDBxEJIjRiyQ4UKf' | chpasswd
#sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
#sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# create user from environment variables
if [ -n "$STUDENTID" ] && [ -n "$PASSWORD" ]; then
	useradd -m $STUDENTID
	echo "$STUDENTID:$PASSWORD" | chpasswd
	chown -R "$STUDENTID:$STUDENTID" /home/$STUDENTID
	chmod 700 /home/$STUDENTID
fi

# add ssh key to user from environment variable
if [ -n "$STUDENTID" ] && [ -n "$SSH_KEY" ]; then
	mkdir -p /home/$STUDENTID/.ssh
	echo "$SSH_KEY" >> /home/$STUDENTID/.ssh/authorized_keys
	chown -R $STUDENTID:$STUDENTID /home/$STUDENTID/.ssh
	chmod 700 /home/$STUDENTID/.ssh
	chmod 600 /home/$STUDENTID/.ssh/authorized_keys
fi

# Set up VNC server configuration
mkdir -p /home/$STUDENTID/.vnc
echo "irFtOvonFXCFMHCfoHmiY2sVfIOLH1E5" | vncpasswd -f > /home/$STUDENTID/.vnc/passwd
chown -R $STUDENTID:$STUDENTID /home/$STUDENTID/.vnc
chmod 600 /home/$STUDENTID/.vnc/passwd
dbus-uuidgen | tee /var/lib/dbus/machine-id
printf "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4 &" > /home/$STUDENTID/.vnc/xstartup
chmod +x /home/$STUDENTID/.vnc/xstartup

# set zsh
sed -i 's|/bin/bash|/bin/zsh|g' /etc/passwd

# start ssh and vnc
/usr/sbin/sshd
rm -rf /tmp/.X*
su - $STUDENTID -c "vncserver :1 -geometry 1280x1024 -depth 24 -SecurityTypes None"
rm /run/nologin
tail -f /dev/null

