#!/bin/bash
# Start PulseAudio
pulseaudio --daemonize=yes --exit-idle-time=-1
pactl load-module module-null-sink sink_name=VirtualSink sink_properties=device.description=VirtualSink

# Launch XFCE desktop
vncserver :1 -geometry 1920x1080 -depth 24

echo "VNC running on display :1"
tail -F /home/poduser/.vnc/*.log
