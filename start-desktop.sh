#!/bin/bash

# Start PulseAudio
pulseaudio --daemonize=yes --exit-idle-time=-1
pactl load-module module-null-sink sink_name=VirtualSink sink_properties=device.description=VirtualSink

# Ensure X authority file exists and is valid
touch ~/.Xauthority
xauth generate :1 . trusted || xauth add :1 . $(mcookie)

# Start VNC server on :1
vncserver :1 -geometry 1920x1080 -depth 24

# Start noVNC on port 6901 (websockify connects to VNC on 5901)
websockify --web=/usr/share/novnc 6901 localhost:5901 &

echo "✅ Desktop environment running!"
echo "🔓 Access via:"
echo "   • VNC Viewer → <host>:5901"
echo "   • Web Browser → http://<host>:6901"
echo "   • Audio sink → VirtualSink"

# Keep container alive
tail -F /home/poduser/.vnc/*.log
