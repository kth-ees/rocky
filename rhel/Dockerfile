# Use the official Rocky Linux 8 image as the base image
FROM redhat/ubi8:latest

ENV container docker
ENV USER root
COPY compat-db47-4.7.25-28.el7.x86_64.rpm /tmp/compat-db47-4.7.25-28.el7.x86_64.rpm
COPY compat-db-headers-4.7.25-28.el7.noarch.rpm /tmp/compat-db-headers-4.7.25-28.el7.noarch.rpm

# Install necessary packages using dnf with --allowerasing option
# RUN dnf install -y epel-release && \
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf update -y --allowerasing && \
    # dnf groupinstall -y "Workstation" --allowerasing && \
    dnf install -y xfce4-panel xfce4-session xfce4-settings xfdesktop xfwm4 \
                   tigervnc-server novnc openssh-server passwd sudo xterm xorg-x11-server-Xvfb \
                   ksh csh redhat-lsb-core libXScrnSaver openssl-devel libicu50 mc qt5-qtbase-gui \
                   libxcb-devel xcb-util-wm xcb-util-image xcb-util-keysyms xcb-util-renderutil \
                   motif motif-devel libpng12 environment-modules git zsh tmux \
                   compat-openssl10 mesa-libGLU libnsl apr-util glibc-devel && \
    dnf install -y /tmp/compat-db-headers-4.7.25-28.el7.noarch.rpm && \
    dnf install -y /tmp/compat-db47-4.7.25-28.el7.x86_64.rpm && \
    dnf clean all


EXPOSE 22

COPY run.sh /run.sh
CMD ["/bin/sh", "/run.sh"]
