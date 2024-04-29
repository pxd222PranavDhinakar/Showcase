#!/bin/bash

# Thresholds
cpu_threshold=75
mem_threshold=70
disk_threshold=80
network_threshold=1000  # KB/s

# Get CPU usage (macOS adjusted command)
cpu_usage=$(top -l 1 -s 0 -n 0 | awk '/CPU usage:/ {print $3}' | sed 's/%//')

# Get Memory usage (macOS adjusted method)
mem_total=$(sysctl hw.memsize | awk '{print $2}')
mem_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
# Converting pages to bytes (assuming page size is 4096 bytes)
mem_free_bytes=$(($mem_free * 4096))
mem_usage=$(echo "scale=2; (1 - $mem_free_bytes / $mem_total) * 100" | bc)

# Get Disk usage (should work on macOS as well)
disk_usage=$(df / | awk 'END{print $5}' | sed 's/%//')

# Network activity: simplified version, monitor data packets instead
network_in_packets=$(netstat -ib | awk '/en0/ && /Link#/{print $7}')  # Replace 'en0' with your network interface
network_out_packets=$(netstat -ib | awk '/en0/ && /Link#/{print $10}') # Replace 'en0' with your network interface

# Check and print alerts
echo "Resource Usage:"
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $mem_usage%"
echo "Disk Usage: $disk_usage%"
echo "Network IN Packets: $network_in_packets"
echo "Network OUT Packets: $network_out_packets"

if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
  echo "Alert: CPU usage is above threshold."
fi
if (( $(echo "$mem_usage > $mem_threshold" | bc -l) )); then
  echo "Alert: Memory usage is above threshold."
fi
if (( $(echo "$disk_usage > $disk_threshold" | bc -l) )); then
  echo "Alert: Disk usage is above threshold."
fi
if [[ "$network_in_packets" -gt "$network_threshold" || "$network_out_packets" -gt "$network_threshold" ]]; then
  echo "Alert: Network activity is above threshold."
fi
