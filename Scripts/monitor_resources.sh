#!/bin/bash

# Thresholds
cpu_threshold=75
mem_threshold=70
disk_threshold=80
network_threshold=1000  # Adjust this to the expected traffic threshold in packets

# Get CPU usage
cpu_usage=$(awk -v FS=" " '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' /proc/stat)

# Get Memory usage
mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
mem_usage=$(echo "scale=2; (1 - $mem_available / $mem_total) * 100" | bc)

# Get Disk usage
disk_usage=$(df / | awk 'END{print $5}' | sed 's/%//')

# Get Network traffic
# Assuming eth0 is the primary network interface, replace 'eth0' with your actual network interface name if different
network_in_packets=$(cat /proc/net/dev | grep eth0 | tr ':' ' ' | awk '{print $2}')
network_out_packets=$(cat /proc/net/dev | grep eth0 | tr ':' ' ' | awk '{print $10}')

# Output and Alerts
echo "Resource Usage:"
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $mem_usage%"
echo "Disk Usage: $disk_usage%"
echo "Network IN Packets: $network_in_packets"
echo "Network OUT Packets: $network_out_packets"

if (( $(echo "$cpu_usage > $cpu_threshold" | bc) )); then
  echo "Alert: CPU usage is above threshold."
fi
if (( $(echo "$mem_usage > $mem_threshold" | bc) )); then
  echo "Alert: Memory usage is above threshold."
fi
if (( $(echo "$disk_usage > $disk_threshold" | bc) )); then
  echo "Alert: Disk usage is above threshold."
fi
if [[ "$network_in_packets" -gt "$network_threshold" || "$network_out_packets" -gt "$network_threshold" ]]; then
  echo "Alert: Network activity is above threshold."
fi
