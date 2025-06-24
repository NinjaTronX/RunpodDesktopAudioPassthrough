FROM ubuntu:22.04

# Install desktop environment, VNC, browser, and audio tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server tigervnc-common \
    firefox pulseaudio pavucontrol \
    ffmpeg sox curl wget nano \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m poduser && echo "poduser:podpass" | chpasswd

USER poduser
WORKDIR /home/poduser

# Set up VNC password
RUN mkdir -p /home/poduser/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd

# Copy startup script
COPY start-desktop.sh /home/poduser/start-desktop.sh
RUN chmod +x /home/poduser/start-desktop.sh

# Expose VNC port
EXPOSE 5901

# Start desktop on container launch
ENTRYPOINT ["/home/poduser/start-desktop.sh"]
