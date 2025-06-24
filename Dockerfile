FROM ubuntu:22.04

# Install core utilities & Cinnamon
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo wget curl gnupg2 nano xauth x11-utils \
    tigervnc-standalone-server tigervnc-common \
    pulseaudio pavucontrol ffmpeg sox \
    cinnamon-desktop-environment \
    openssh-server \
    websockify novnc \
    && rm -rf /var/lib/apt/lists/*

# Install real Firefox (non-Snap)
RUN mkdir -p /opt/firefox && \
    curl -L -o /tmp/firefox.tar.bz2 "https://ftp.mozilla.org/pub/firefox/releases/latest/linux-x86_64/en-US/firefox-*.tar.bz2" && \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt/firefox --strip-components=1 && \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox && \
    rm -f /tmp/firefox.tar.bz2

# Create poduser with sudo and a password
RUN useradd -m -s /bin/bash poduser && echo "poduser:podpass" | chpasswd && \
    usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Root user access for SSH
RUN echo "root:rootpass" | chpasswd && \
    mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Copy and fix permissions of the startup script
COPY start-desktop.sh /tmp/start-desktop.sh
RUN chmod +x /tmp/start-desktop.sh && \
    chown poduser:poduser /tmp/start-desktop.sh && \
    mv /tmp/start-desktop.sh /home/poduser/start-desktop.sh

USER poduser
WORKDIR /home/poduser

# Prepare VNC and Xauthority
RUN mkdir -p /home/poduser/.vnc && \
    printf "podpass\npodpass\nn\n" | vncpasswd && \
    touch /home/poduser/.Xauthority

# Expose SSH, VNC, and WebVNC
EXPOSE 22 5901 6901

ENTRYPOINT ["/home/poduser/start-desktop.sh"]
