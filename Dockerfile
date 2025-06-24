FROM ubuntu:22.04

# Install desktop, VNC, browser, audio tools test
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server tigervnc-common \
    firefox pulseaudio pavucontrol \
    ffmpeg sox \
    && rm -rf /var/lib/apt/lists/*

# Setup PulseAudio config
RUN useradd -m poduser && echo "poduser:podpass" | chpasswd
USER poduser
WORKDIR /home/poduser

# VNC password
RUN mkdir ~/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd

# Init script
COPY start-desktop.sh /home/poduser/start-desktop.sh
RUN chmod +x start-desktop.sh

ENTRYPOINT ["./start-desktop.sh"]
CMD []
