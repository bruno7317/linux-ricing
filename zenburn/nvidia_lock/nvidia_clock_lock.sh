#!/bin/bash

LOGFILE="/var/log/nvidia-clock-lock.log"

{
  echo "[$(date)] Starting NVIDIA clock lock..."
  /usr/bin/nvidia-smi -pm 1
  /usr/bin/nvidia-smi --lock-gpu-clocks=210,1725
  echo "[$(date)] Lock applied."
  /usr/bin/nvidia-smi --query-gpu=clocks.current.graphics --format=csv
} >> "$LOGFILE" 2>&1
