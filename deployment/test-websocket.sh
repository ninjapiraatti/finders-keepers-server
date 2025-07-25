#!/bin/bash

# Simple WebSocket Test Client
# Tests the connection to the Finders Keepers server

if [ $# -eq 0 ]; then
    echo "Usage: $0 <server_ip_or_hostname>"
    echo "Example: $0 192.168.1.100"
    echo "Example: $0 localhost"
    exit 1
fi

SERVER=$1
PORT=8087
URL="ws://$SERVER:$PORT"

echo "🧪 Testing WebSocket connection to: $URL"
echo "==============================================="

# Test 1: Basic connectivity
echo "1. Testing basic TCP connectivity..."
if command -v nc &> /dev/null; then
    if timeout 3 nc -z $SERVER $PORT 2>/dev/null; then
        echo "   ✅ TCP connection successful"
    else
        echo "   ❌ TCP connection failed"
        echo "   💡 Server may not be running or port may be blocked"
        exit 1
    fi
else
    echo "   ⚠️  netcat not available, skipping TCP test"
fi

# Test 2: HTTP upgrade request (simulating WebSocket handshake)
echo ""
echo "2. Testing WebSocket handshake..."
if command -v curl &> /dev/null; then
    RESPONSE=$(curl -s -I \
        -H "Connection: Upgrade" \
        -H "Upgrade: websocket" \
        -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
        -H "Sec-WebSocket-Version: 13" \
        http://$SERVER:$PORT 2>&1)
    
    if echo "$RESPONSE" | grep -q "101"; then
        echo "   ✅ WebSocket handshake successful (HTTP 101)"
    elif echo "$RESPONSE" | grep -q "Connection refused"; then
        echo "   ❌ Connection refused - server not listening"
    elif echo "$RESPONSE" | grep -q "timeout"; then
        echo "   ❌ Connection timeout - server may be unreachable"
    else
        echo "   ⚠️  Unexpected response:"
        echo "$RESPONSE" | head -3 | sed 's/^/      /'
    fi
else
    echo "   ⚠️  curl not available, skipping handshake test"
fi

# Test 3: Create a simple Node.js test if available
echo ""
echo "3. Testing with WebSocket client..."

# Create a temporary Node.js script if node is available
if command -v node &> /dev/null; then
    cat > /tmp/ws_test.js << 'EOF'
const WebSocket = require('ws');

const url = process.argv[2];
console.log(`Connecting to: ${url}`);

const ws = new WebSocket(url);

ws.on('open', function open() {
    console.log('✅ WebSocket connection established!');
    
    // Send a test message
    const testMessage = {
        type: "Join",
        player_name: "TestPlayer"
    };
    
    console.log('📤 Sending test message:', JSON.stringify(testMessage));
    ws.send(JSON.stringify(testMessage));
    
    // Close after a short delay
    setTimeout(() => {
        ws.close();
    }, 2000);
});

ws.on('message', function message(data) {
    console.log('📥 Received message:', data.toString());
});

ws.on('error', function error(err) {
    console.log('❌ WebSocket error:', err.message);
    process.exit(1);
});

ws.on('close', function close() {
    console.log('🔌 WebSocket connection closed');
    process.exit(0);
});

// Timeout after 5 seconds
setTimeout(() => {
    console.log('❌ Connection timeout');
    process.exit(1);
}, 5000);
EOF

    # Check if ws module is available
    if node -e "require('ws')" 2>/dev/null; then
        timeout 10 node /tmp/ws_test.js $URL
    else
        echo "   ⚠️  ws module not available, install with: npm install -g ws"
        echo "   💡 Or test manually in browser console:"
        echo "      ws = new WebSocket('$URL')"
        echo "      ws.onopen = () => console.log('Connected!')"
        echo "      ws.onerror = (e) => console.log('Error:', e)"
    fi
    
    # Clean up
    rm -f /tmp/ws_test.js
else
    echo "   ⚠️  Node.js not available"
    echo "   💡 Test manually in browser console:"
    echo "      ws = new WebSocket('$URL')"
    echo "      ws.onopen = () => console.log('Connected!')"
    echo "      ws.onerror = (e) => console.log('Error:', e)"
fi

echo ""
echo "🔗 Manual test URLs:"
echo "   Browser console: new WebSocket('$URL')"
echo "   Test client: file://$(dirname $0)/../test_client.html"

echo ""
echo "💡 Common issues and solutions:"
echo "   - Connection refused: Server not running"
echo "   - Timeout: Firewall blocking port $PORT"
echo "   - 404 Not Found: Server running on wrong port"
echo "   - CORS issues: Not applicable to WebSockets"
