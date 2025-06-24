#!/bin/bash

# Start PulseAudio
pulseaudio --daemonize=yes --exit-idle-time=-1
pactl load-module module-null-sink sink_name=VirtualSink sink_properties=device.description=VirtualSink

# X Authority fix
touch ~/.Xauthority
xauth generate :1 . trusted || xauth add :1 . $(mcookie)

# Start VNC server
vncserver :1 -geometry 1920x1080 -depth 24

# Start noVNC
websockify --web=/usr/share/novnc 6901 localhost:5901 &

# Start SSH daemon
sudo /usr/sbin/sshd

echo "✅ Desktop + SSH running!"
echo "   VNC:        <host>:5901"
echo "   Web VNC:    http://<host>:6901"
echo "   SSH:        ssh root@<host> -p 22  (or poduser)"

# Keep container alive
tail -F /home/poduser/.vnc/*.log
