FROM ubuntu:22.04

# Install Cinnamon desktop, Firefox (via apt), and essentials
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cinnamon-desktop-environment \
    firefox \
    tigervnc-standalone-server tigervnc-common \
    pulseaudio pavucontrol \
    ffmpeg sox curl wget nano sudo \
    xauth x11-utils \
    openssh-server \
    websockify novnc \
    && rm -rf /var/lib/apt/lists/*

# Create poduser with sudo access
RUN useradd -m -s /bin/bash poduser && echo "poduser:podpass" | chpasswd && \
    usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Enable SSH root access
RUN echo "root:rootpass" | chpasswd && \
    mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Copy startup script
COPY start-desktop.sh /tmp/start-desktop.sh
RUN chmod +x /tmp/start-desktop.sh && \
    chown poduser:poduser /tmp/start-desktop.sh && \
    mv /tmp/start-desktop.sh /home/poduser/start-desktop.sh

USER poduser
WORKDIR /home/poduser

# Set up VNC password and Xauthority
RUN mkdir -p /home/poduser/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd && \
    touch /home/poduser/.Xauthority

# Expose ports
EXPOSE 22 5901 6901

ENTRYPOINT ["/home/poduser/start-desktop.sh"]
