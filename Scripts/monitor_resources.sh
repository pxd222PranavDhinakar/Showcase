#!/bin/bash

# Thresholds
cpu_threshold=75
mem_threshold=70
disk_threshold=80
network_threshold=10000000  # Adjust based on expected traffic, either in packets or bytes

# macOS-specific commands
if [[ "$(uname)" == "Darwin" ]]; then
    cpu_usage=$(top -l 1 | awk '/CPU usage/ {print $3}' | sed 's/%//')
    mem_total=$(sysctl hw.memsize | awk '{print $2}')
    mem_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    mem_free_bytes=$(($mem_free * 4096))
    mem_usage=$(echo "scale=2; (1 - $mem_free_bytes / $mem_total) * 100" | bc)
    network_in_packets=$(netstat -ib | awk '/en0/ && /Link#/ {sum+=$7} END {print sum}')  # Summing up all entries
    network_out_packets=$(netstat -ib | awk '/en0/ && /Link#/ {sum+=$10} END {print sum}') # Summing up all entries
else
    # Add Linux-specific methods if needed
    echo "This part of the script is for Linux adjustments."
fi

# Output and Alerts
echo "Resource Usage:"
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $mem_usage%"
echo "Disk Usage: $(df / | awk 'END{print $5}' | sed 's/%//')%"
echo "Network IN Packets: $network_in_packets"
echo "Network OUT Packets: $network_out_packets"

if (( $(echo "$cpu_usage > $cpu_threshold" | bc) )); then
  echo "Alert: CPU usage is above threshold."
fi
if (( $(echo "$mem_usage > $mem_threshold" | bc) )); then
  echo "Alert: Memory usage is above threshold."
fi
if (( $(echo "$(df / | awk 'END{print $5}' | sed 's/%//') > $disk_threshold" | bc) )); then
  echo "Alert: Disk usage is above threshold."
fi
if [[ "$network_in_packets" -gt "$network_threshold" || "$network_out_packets" -gt "$network_threshold" ]]; then
  echo "Alert: Network activity is above threshold."
fi
