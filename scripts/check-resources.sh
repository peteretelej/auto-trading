#!/bin/bash
set -e

echo "=== SYSTEM RESOURCE CHECK ==="
echo ""

# Check CPU usage
echo "CPU Usage by Bot Containers:"
echo "---------------------------------"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep freqtrade

# Check Memory
echo ""
echo "System Memory Status:"
echo "---------------------------------"
free -h

# Check Disk Space
echo ""
echo "Disk Space Status:"
echo "---------------------------------"
df -h | grep -E '/$|/home'

# Check Docker Space
echo ""
echo "Docker Disk Usage:"
echo "---------------------------------"
docker system df

echo ""
echo "=== END RESOURCE CHECK ===" 