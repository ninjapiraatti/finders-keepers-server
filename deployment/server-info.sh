#!/bin/bash

# Server Information Script
# Displays comprehensive information about the Finders Keepers Server

echo "🎮 Finders Keepers Server Information"
echo "====================================="
echo ""

# Check if Docker version exists
if command -v docker &> /dev/null; then
    echo "🐳 Docker Deployment:"
    if [ -f "/opt/finders-keepers/docker-compose.yml" ]; then
        echo "   Status: ✅ Installed"
        echo "   Location: /opt/finders-keepers/"
        
        # Check if container is running
        if docker ps | grep -q finders-keepers-server; then
            echo "   Container: ✅ Running"
            
            # Get container info
            CONTAINER_ID=$(docker ps | grep finders-keepers-server | awk '{print $1}')
            UPTIME=$(docker ps | grep finders-keepers-server | awk '{print $9,$10}')
            echo "   Uptime: $UPTIME"
            
            # Check port
            if netstat -tuln 2>/dev/null | grep -q :8087; then
                echo "   Port 8087: ✅ Listening"
            else
                echo "   Port 8087: ❌ Not listening"
            fi
        else
            echo "   Container: ❌ Not running"
        fi
    else
        echo "   Status: ❌ Not installed"
    fi
else
    echo "🐳 Docker: ❌ Not installed"
fi

echo ""

# Check for systemd binary deployment
if [ -f "/opt/finders-keepers/finders-keepers-server" ]; then
    echo "⚙️  Binary Deployment:"
    echo "   Status: ✅ Installed"
    echo "   Location: /opt/finders-keepers/finders-keepers-server"
    
    # Check systemd service
    if systemctl is-active --quiet finders-keepers; then
        echo "   Service: ✅ Running"
        UPTIME=$(systemctl show finders-keepers --property=ActiveEnterTimestamp --value)
        echo "   Started: $UPTIME"
    else
        echo "   Service: ❌ Not running"
    fi
else
    echo "⚙️  Binary Deployment: ❌ Not installed"
fi

echo ""

# Network information
echo "🌐 Network Information:"
if command -v curl &> /dev/null; then
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to detect")
    echo "   Public IP: $PUBLIC_IP"
else
    echo "   Public IP: Unable to detect (curl not installed)"
fi

LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "Unable to detect")
echo "   Local IP: $LOCAL_IP"

if netstat -tuln 2>/dev/null | grep -q :8087; then
    echo "   Port 8087: ✅ Listening"
    echo "   WebSocket URL: ws://$PUBLIC_IP:8087"
    echo "   Local URL: ws://localhost:8087"
else
    echo "   Port 8087: ❌ Not listening"
fi

echo ""

# System information
echo "💻 System Information:"
echo "   OS: $(lsb_release -d 2>/dev/null | cut -f2 || uname -s)"
echo "   Kernel: $(uname -r)"
echo "   Uptime: $(uptime -p 2>/dev/null || uptime)"

# Memory and CPU
if command -v free &> /dev/null; then
    MEMORY=$(free -h | awk '/^Mem:/ {print $2 " total, " $3 " used"}')
    echo "   Memory: $MEMORY"
fi

if command -v nproc &> /dev/null; then
    CPU_CORES=$(nproc)
    echo "   CPU Cores: $CPU_CORES"
fi

echo ""

# Firewall status
echo "🔥 Firewall:"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1)
    echo "   UFW: $UFW_STATUS"
    
    if sudo ufw status 2>/dev/null | grep -q "8087"; then
        echo "   Port 8087: ✅ Allowed"
    else
        echo "   Port 8087: ⚠️  Not explicitly allowed"
    fi
else
    echo "   UFW: Not installed"
fi

echo ""

# Available management commands
echo "🛠️  Available Commands:"
if [ -f "/opt/finders-keepers/start.sh" ]; then
    echo "   /opt/finders-keepers/start.sh       - Start server"
    echo "   /opt/finders-keepers/stop.sh        - Stop server"
    echo "   /opt/finders-keepers/status.sh      - Check status"
    echo "   /opt/finders-keepers/update.sh      - Update server"
    echo "   /opt/finders-keepers/health-check.sh - Health check"
fi

if systemctl list-unit-files | grep -q finders-keepers; then
    echo "   sudo systemctl status finders-keepers    - Service status"
    echo "   sudo journalctl -u finders-keepers -f    - View logs"
fi

echo ""

# Quick health check
echo "🏥 Quick Health Check:"
if netstat -tuln 2>/dev/null | grep -q :8087; then
    echo "   ✅ Server is listening on port 8087"
    
    # Test if we can connect (basic check)
    if timeout 3 bash -c "</dev/tcp/localhost/8087" 2>/dev/null; then
        echo "   ✅ Port 8087 is accessible"
    else
        echo "   ⚠️  Port 8087 may not be fully ready"
    fi
else
    echo "   ❌ Server is not listening on port 8087"
fi

echo ""
echo "For detailed setup instructions, visit:"
echo "https://github.com/ninjapiraatti/finders-keepers-server/blob/main/deployment/QUICK-SETUP.md"
