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

# Switch to root user's home temporarily for script copy
WORKDIR /root

# Copy startup script with correct permissions and ownership
COPY start-desktop.sh /tmp/start-desktop.sh
RUN chmod +x /tmp/start-desktop.sh && \
    chown poduser:poduser /tmp/start-desktop.sh && \
    mv /tmp/start-desktop.sh /home/poduser/start-desktop.sh

# Set up VNC password as poduser
USER poduser
RUN mkdir -p /home/poduser/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd

WORKDIR /home/poduser

# Expose VNC port
EXPOSE 5901

# Start desktop on container launch
ENTRYPOINT ["/home/poduser/start-desktop.sh"]
