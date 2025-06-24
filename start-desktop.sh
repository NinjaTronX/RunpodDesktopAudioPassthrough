#!/bin/bash

# Start PulseAudio
pulseaudio --daemonize=yes --exit-idle-time=-1
pactl load-module module-null-sink sink_name=VirtualSink sink_properties=device.description=VirtualSink

# Fix missing .Xauthority
touch ~/.Xauthority
xauth generate :1 . trusted || xauth add :1 . $(mcookie)

# Start VNC server with Cinnamon
vncserver :1 -geometry 1920x1080 -depth 24
export DISPLAY=:1

# Use Cinnamon session
echo "cinnamon-session" > ~/.xsession

# Start noVNC
websockify --web=/usr/share/novnc 6901 localhost:5901 &

# Start SSH daemon
sudo /usr/sbin/sshd

echo "✅ Cinnamon Desktop Ready"
echo "   SSH:       root/rootpass or poduser/podpass on port 22"
echo "   VNC:       <host>:5901"
echo "   Browser:   http://<host>:6901"

# Keep container alive
tail -F /home/poduser/.vnc/*.log
