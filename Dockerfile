FROM ubuntu:22.04

# Base packages and Cinnamon desktop (core only)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cinnamon-core \
    firefox \
    tigervnc-standalone-server tigervnc-common \
    dbus-x11 x11-utils xauth \
    pulseaudio pavucontrol ffmpeg sox \
    websockify novnc \
    sudo curl wget nano lsof \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user with sudo access
RUN useradd -m -s /bin/bash poduser && echo "poduser:podpass" | chpasswd && \
    usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Allow SSH root login (optional)
RUN echo "root:rootpass" | chpasswd && \
    mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Add and set permissions for start-desktop script
COPY start-desktop.sh /tmp/start-desktop.sh
RUN chmod +x /tmp/start-desktop.sh && \
    mv /tmp/start-desktop.sh /home/poduser/start-desktop.sh && \
    chown poduser:poduser /home/poduser/start-desktop.sh

USER poduser
WORKDIR /home/poduser

# Set up VNC password and Xauthority
RUN mkdir -p /home/poduser/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd && \
    touch /home/poduser/.Xauthority

EXPOSE 22 5901 6901

ENTRYPOINT ["/home/poduser/start-desktop.sh"]
