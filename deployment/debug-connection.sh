#!/bin/bash

# WebSocket Connection Debugging Script
# This script helps diagnose why clients can't connect to the Finders Keepers server

echo "🔍 WebSocket Connection Debugging"
echo "=================================="
echo ""

# Get server info
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to detect")
LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "Unable to detect")

echo "🌐 Network Information:"
echo "   Public IP: $PUBLIC_IP"
echo "   Local IP: $LOCAL_IP"
echo ""

# Check if server is running
echo "🏃 Server Status:"
if docker ps | grep -q finders-keepers-server; then
    echo "   ✅ Container is running"
    CONTAINER_ID=$(docker ps | grep finders-keepers-server | awk '{print $1}')
    echo "   📋 Container ID: $CONTAINER_ID"
else
    echo "   ❌ Container is NOT running"
    echo "   💡 Try: /opt/finders-keepers/start.sh"
    exit 1
fi

echo ""

# Check port binding
echo "🔌 Port Status:"
if netstat -tuln 2>/dev/null | grep -q ":8087"; then
    echo "   ✅ Port 8087 is listening"
    PORT_INFO=$(netstat -tuln 2>/dev/null | grep ":8087")
    echo "   📋 Port details: $PORT_INFO"
else
    echo "   ❌ Port 8087 is NOT listening"
    echo "   💡 Check container port mapping"
fi

echo ""

# Check Docker port mapping
echo "🐳 Docker Port Mapping:"
DOCKER_PORTS=$(docker port finders-keepers-server 2>/dev/null || echo "No port mapping found")
echo "   📋 Mapped ports: $DOCKER_PORTS"

echo ""

# Check firewall
echo "🔥 Firewall Status:"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1)
    echo "   📋 UFW: $UFW_STATUS"
    
    if sudo ufw status 2>/dev/null | grep -q "8087"; then
        echo "   ✅ Port 8087 is allowed in firewall"
        UFW_RULE=$(sudo ufw status 2>/dev/null | grep "8087")
        echo "   📋 Rule: $UFW_RULE"
    else
        echo "   ⚠️  Port 8087 is NOT explicitly allowed in firewall"
        echo "   💡 Try: sudo ufw allow 8087/tcp"
    fi
else
    echo "   📋 UFW not installed"
fi

# Check iptables if UFW shows inactive
if command -v iptables &> /dev/null; then
    IPTABLES_RULES=$(sudo iptables -L INPUT -n 2>/dev/null | grep -c "8087" || echo "0")
    if [ "$IPTABLES_RULES" -gt 0 ]; then
        echo "   📋 Found $IPTABLES_RULES iptables rules for port 8087"
    fi
fi

echo ""

# Test local connectivity
echo "🧪 Local Connection Test:"
if timeout 3 bash -c "</dev/tcp/localhost/8087" 2>/dev/null; then
    echo "   ✅ Can connect to localhost:8087"
else
    echo "   ❌ CANNOT connect to localhost:8087"
    echo "   💡 Server may not be listening correctly"
fi

# Test local IP connectivity
if timeout 3 bash -c "</dev/tcp/$LOCAL_IP/8087" 2>/dev/null; then
    echo "   ✅ Can connect to $LOCAL_IP:8087"
else
    echo "   ❌ CANNOT connect to $LOCAL_IP:8087"
    echo "   💡 Check if server binds to all interfaces"
fi

echo ""

# Check container logs
echo "📝 Recent Container Logs:"
echo "   (Last 10 lines)"
echo "   ===================="
docker logs --tail=10 finders-keepers-server 2>/dev/null || echo "   ❌ Could not fetch logs"

echo ""

# WebSocket-specific tests
echo "🌐 WebSocket Connection Tests:"

# Test with curl if available
if command -v curl &> /dev/null; then
    echo "   Testing HTTP connection (WebSocket upgrade)..."
    HTTP_RESPONSE=$(curl -s -I -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" http://localhost:8087 2>/dev/null | head -1 || echo "Connection failed")
    echo "   📋 HTTP Response: $HTTP_RESPONSE"
fi

# Test with nc if available
if command -v nc &> /dev/null; then
    echo "   Testing raw TCP connection..."
    if timeout 2 nc -z localhost 8087 2>/dev/null; then
        echo "   ✅ TCP connection successful"
    else
        echo "   ❌ TCP connection failed"
    fi
fi

echo ""

# Check server configuration
echo "⚙️  Server Configuration:"
if [ -f "/opt/finders-keepers/docker-compose.yml" ]; then
    echo "   📋 Port mapping from docker-compose.yml:"
    grep -A 3 -B 1 "ports:" /opt/finders-keepers/docker-compose.yml | sed 's/^/      /'
else
    echo "   ❌ docker-compose.yml not found"
fi

echo ""

# Provide connection URLs for testing
echo "🔗 Connection URLs to Test:"
echo "   Local (from server):     ws://localhost:8087"
echo "   Local network:           ws://$LOCAL_IP:8087"
echo "   Public (from internet):  ws://$PUBLIC_IP:8087"

echo ""

# Provide troubleshooting steps
echo "🛠️  Troubleshooting Steps:"
echo "   1. If container not running: /opt/finders-keepers/start.sh"
echo "   2. If port not listening: Check container logs above"
echo "   3. If firewall blocking: sudo ufw allow 8087/tcp"
echo "   4. If still issues: /opt/finders-keepers/stop.sh && /opt/finders-keepers/start.sh"

echo ""

# Advanced debugging
echo "🔬 Advanced Debugging:"
echo "   View full logs: docker logs -f finders-keepers-server"
echo "   Container shell: docker exec -it finders-keepers-server sh"
echo "   Restart server: /opt/finders-keepers/stop.sh && /opt/finders-keepers/start.sh"
echo "   Check processes: docker exec finders-keepers-server ps aux"

echo ""
echo "📞 If you need to test the WebSocket connection from a browser:"
echo "   1. Open browser developer tools (F12)"
echo "   2. Go to Console tab"
echo "   3. Type: ws = new WebSocket('ws://$PUBLIC_IP:8087')"
echo "   4. Check for connection errors"
