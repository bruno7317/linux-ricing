#!/bin/bash

# === CONFIG ===
SCRIPT_SOURCE="./nvidia_clock_lock.sh"
SERVICE_SOURCE="./nvidia-clock-lock.service"
SCRIPT_TARGET="/usr/local/bin/nvidia-clock-lock.sh"
SERVICE_TARGET="/etc/systemd/system/nvidia-clock-lock.service"
LOGFILE="/var/log/nvidia-clock-lock.log"

# === COPY FILES ===
echo "Installing NVIDIA clock lock script and service..."
sudo cp "$SCRIPT_SOURCE" "$SCRIPT_TARGET" || exit 1
sudo cp "$SERVICE_SOURCE" "$SERVICE_TARGET" || exit 1

# === PERMISSIONS ===
sudo chmod +x "$SCRIPT_TARGET"

# === SETUP SYSTEMD SERVICE ===
echo "Setting up systemd service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nvidia-clock-lock.service

# === CREATE LOG FILE (optional) ===
if [ ! -f "$LOGFILE" ]; then
  echo "Creating log file at $LOGFILE"
  sudo touch "$LOGFILE"
  sudo chown "$USER:$USER" "$LOGFILE"
fi

# === DONE ===
echo "Done. NVIDIA GPU clock lock is set to apply automatically after every reboot."