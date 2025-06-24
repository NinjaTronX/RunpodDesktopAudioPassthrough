#!/bin/bash

# Kill old sessions
vncserver -kill :1 > /dev/null 2>&1
pkill websockify || true

# Setup xstartup for Cinnamon session
mkdir -p ~/.vnc
cat <<EOF > ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval \$(dbus-launch --sh-syntax)
[ -r \$HOME/.Xresources ] && xrdb \$HOME/.Xresources
exec cinnamon-session &
EOF
chmod +x ~/.vnc/xstartup

# Start PulseAudio (safe)
if ! pgrep -x pulseaudio > /dev/null; then
  pulseaudio --start --exit-idle-time=-1
fi
pactl load-module module-null-sink sink_name=VirtualSink sink_properties=device.description=VirtualSink

# Launch VNC
vncserver :1 -geometry 1920x1080 -depth 24
export DISPLAY=:1

# Launch websockify only if needed
if ! lsof -i:6901 > /dev/null; then
  websockify --web=/usr/share/novnc 6901 localhost:5901 &
fi

# Start SSH
sudo /usr/sbin/sshd

echo "🎉 Cinnamon Desktop launched on VNC"
tail -F ~/.vnc/*.log
