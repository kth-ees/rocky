# Use the official Rocky Linux 8 image as the base image
FROM rockylinux:8

ENV container docker
ENV USER root

# Install necessary packages using dnf with --allowerasing option
RUN dnf install -y epel-release && \
    dnf update -y --allowerasing && \
    dnf groupinstall -y "Server with GUI" --allowerasing && \
    dnf install -y xfce4-panel xfce4-session xfce4-settings xfdesktop xfwm4 \
                   tigervnc-server novnc openssh-server passwd sudo xterm \
                   ksh csh redhat-lsb-core libXScrnSaver openssl-devel \
                   motif motif-devel libpng12 \
                   compat-openssl10 mesa-libGLU libnsl apr-util glibc-devel && \
    dnf install -y https://rpmfind.net/linux/centos/7.9.2009/os/x86_64/Packages/compat-db-headers-4.7.25-28.el7.noarch.rpm && \
    dnf install -y https://rpmfind.net/linux/centos/7.9.2009/os/x86_64/Packages/compat-db47-4.7.25-28.el7.x86_64.rpm && \
    dnf clean all

# Set up SSH server
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A && \ 
    echo 'root:password' | chpasswd && \
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Set up VNC server configuration
RUN mkdir -p /root/.vnc && \
    echo "password" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    dbus-uuidgen | tee /var/lib/dbus/machine-id && \
    printf "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Expose the SSH port
EXPOSE 22
EXPOSE 3000

# License
ENV LM_LICENSE_FILE 1717@lic06.ug.kth.se:27020@lic05.ug.kth.se:3000@lic08.ug.kth.se
# Copy installscape

# COPY IScape05.01-p001lnx86.t.Z /opt/iscape.tar.gz
#COPY unknown80httpbasic /unknown80httpbasic  
#
#RUN mkdir -p /opt/cadence/iscape && \
#    mkdir -p /root/.iscape/root && \
#    mv /unknown80httpbasic  /root/.iscape/root/ && \
#    cd /opt/cadence/iscape && \
#    tar xvf /iscape.t.Z
#
#
#RUN mkdir -p /opt/cadence/GENUS211 && \
#    /opt/cadence/iscape/iscape.05.01-p001/bin/iscape.sh -batch majoraction=download minoraction=install \ 
#      sourcelocation=http://sw.cadence.com/is/GENUS211/lnx86/Base installdirectory=/opt/cadence/GENUIS211
#
COPY run.sh /run.sh
CMD ["/bin/sh", "/run.sh"]
