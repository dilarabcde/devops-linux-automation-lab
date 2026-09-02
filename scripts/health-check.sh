#!/bin/bash

echo "System Health Check"
echo "-------------------"

STATUS=0

# Disk Check
echo "Disk Usage:"

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

echo "Disk Usage: $DISK_USAGE%"

if [ "$DISK_USAGE" -ge 80 ]; then
    echo "WARNING: Disk usage is high"
    STATUS=1
else
    echo "OK: Disk usage is normal"
fi


# Process Check
echo "Process Check:"

if pgrep sleep > /dev/null; then
    echo "OK: Process is running"
else
    echo "WARNING: Process is not running"
    STATUS=1
fi


# Memory Check
echo "Memory Usage:"

TOTAL_MEM=$(free -m | awk 'NR==2 {print $2}')
AVAILABLE_MEM=$(free -m | awk 'NR==2 {print $7}')

AVAILABLE_PERCENT=$(( AVAILABLE_MEM * 100 / TOTAL_MEM ))

echo "Available Memory: $AVAILABLE_PERCENT%"

if [ "$AVAILABLE_PERCENT" -lt 20 ]; then
    echo "WARNING: Available memory is low"
    STATUS=1
else
    echo "OK: Available memory is sufficient"
fi


exit $STATUS
