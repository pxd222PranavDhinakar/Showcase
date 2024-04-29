#!/bin/bash

# Thresholds
cpu_threshold=75
mem_threshold=70
disk_threshold=80
network_threshold=1000  # Adjust this to the expected traffic threshold in packets

# Get CPU usage
# Read /proc/stat CPU line, wait a second, read again, and calculate usage
prev_idle=$(awk '/^cpu /{print $5}' /proc/stat)
prev_total=$(awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8}' /proc/stat)
sleep 1
idle=$(awk '/^cpu /{print $5}' /proc/stat)
total=$(awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8}' /proc/stat)

idle_delta=$((idle-prev_idle))
total_delta=$((total-prev_total))
if [[ $total_delta -eq 0 ]]; then
    cpu_usage=0
else
    cpu_usage=$((100*(1-$idle_delta/$total_delta)))
fi

# Get Memory usage
mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
mem_usage=$(echo "scale=2; (1 - $mem_available / $mem_total) * 100" | bc)

# Get Disk usage
disk_usage=$(df / | awk 'END{print $5}' | sed 's/%//')

# Get Network traffic
# Read /proc/net/dev for network packets, ensuring interface exists
network_interface="eth0"  # Change to your actual interface
if grep -q "$network_interface" /proc/net/dev; then
    network_in_packets=$(cat /proc/net/dev | grep "$network_interface" | tr ':' ' ' | awk '{print $2}')
    network_out_packets=$(cat /proc/net/dev | grep "$network_interface" | tr ':' ' ' | awk '{print $10}')
else
    network_in_packets="No data"
    network_out_packets="No data"
fi

# Output and Alerts
echo "Resource Usage:"
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $mem_usage%"
echo "Disk Usage: $disk_usage%"
echo "Network IN Packets: $network_in_packets"
echo "Network OUT Packets: $network_out_packets"

# Check conditions and output alerts
if [[ $cpu_usage -gt $cpu_threshold ]]; then
  echo "Alert: CPU usage is above threshold."
fi
if (( $(echo "$mem_usage > $mem_threshold" | bc) )); then
  echo "Alert: Memory usage is above threshold."
fi
if (( $(echo "$disk_usage > $disk_threshold" | bc) )); then
  echo "Alert: Disk usage is above threshold."
fi
if [[ $network_in_packets =~ ^[0-9]+$ && $network_in_packets -gt $network_threshold || $network_out_packets =~ ^[0-9]+$ && $network_out_packets -gt $network_threshold ]]; then
  echo "Alert: Network activity is above threshold."
fi
