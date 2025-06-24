FROM ubuntu:22.04

# Install everything: GUI, audio, browser, sudo, SSH, VNC, noVNC
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server tigervnc-common \
    firefox pulseaudio pavucontrol \
    ffmpeg sox curl wget nano sudo \
    openssh-server \
    xauth x11-utils \
    websockify novnc \
    && rm -rf /var/lib/apt/lists/*

# Create poduser with sudo access
RUN useradd -m -s /bin/bash poduser && echo "poduser:podpass" | chpasswd && \
    usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH server
RUN mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Set root password
RUN echo "root:rootpass" | chpasswd

# Copy and fix permissions of the startup script
COPY start-desktop.sh /tmp/start-desktop.sh
RUN chmod +x /tmp/start-desktop.sh && \
    chown poduser:poduser /tmp/start-desktop.sh && \
    mv /tmp/start-desktop.sh /home/poduser/start-desktop.sh

USER poduser
WORKDIR /home/poduser

# Set up VNC and .Xauthority
RUN mkdir -p /home/poduser/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd && \
    touch /home/poduser/.Xauthority

# Expose SSH (22), VNC (5901), noVNC (6901)
EXPOSE 22 5901 6901

# Run everything via script
ENTRYPOINT ["/home/poduser/start-desktop.sh"]
