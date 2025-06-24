FROM ubuntu:22.04

# Install desktop environment, VNC, browser, audio, and web VNC tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server tigervnc-common \
    firefox pulseaudio pavucontrol \
    ffmpeg sox curl wget nano \
    xauth x11-utils \
    websockify novnc \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m poduser && echo "poduser:podpass" | chpasswd

# Copy startup script as root, then fix permissions
COPY start-desktop.sh /tmp/start-desktop.sh
RUN chmod +x /tmp/start-desktop.sh && \
    chown poduser:poduser /tmp/start-desktop.sh && \
    mv /tmp/start-desktop.sh /home/poduser/start-desktop.sh

USER poduser
WORKDIR /home/poduser

# Set up VNC password and .Xauthority (fixes missing X11 auth)
RUN mkdir -p /home/poduser/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd && \
    touch /home/poduser/.Xauthority

# Expose both VNC and noVNC ports
EXPOSE 5901 6901

ENTRYPOINT ["/home/poduser/start-desktop.sh"]
