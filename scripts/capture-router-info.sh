#!/bin/bash

DEVICE=/dev/ttyUSB0
BAUDRATE=115200
LOGFILE="router-info-$(date +%Y%m%d_%H%M%S).log"

# Commands to execute on the router
read -r -d '' COMMANDS << 'EOF'
echo "=== CPUINFO ==="
cat /proc/cpuinfo
echo "=== DMESG ==="
dmesg
echo "=== MTD ==="
cat /proc/mtd
echo "=== PARTITIONS ==="
cat /proc/partitions
echo "=== OS-RELEASE ==="
cat /etc/os-release
echo "=== UNAME ==="
uname -a
echo "=== INTERFACES ==="
ifconfig -a
echo "=== FILESYSTEM ==="
df -h
echo "=== MEMORY ==="
free -m
EOF

echo "Starting UART logging with screen to $LOGFILE"

# Start screen session logging in detached mode
screen -dmS router-session -L -Logfile "$LOGFILE" $DEVICE $BAUDRATE

sleep 2

# Send commands line by line to UART via screen
while read -r CMD; do
  # Skip empty lines
  [ -z "$CMD" ] && continue

  # Send command + newline to screen session
  screen -S router-session -X stuff "$CMD"$(echo -ne '\r')

  # Wait a moment for output to appear clearly in logs
  sleep 2
done <<< "$COMMANDS"

echo "Waiting for final data..."
sleep 5

# Close screen session
screen -S router-session -X quit

echo "Captured data is in: $LOGFILE"
