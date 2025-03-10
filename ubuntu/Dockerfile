# Use the official Ubuntu 22.04 image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    openssh-server \
    git \
    tmux \
    zsh \
    environment-modules && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 22

COPY run.sh /run.sh
CMD ["/bin/sh", "/run.sh"]
