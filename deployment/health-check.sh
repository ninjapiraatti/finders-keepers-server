#!/bin/bash
echo "🏥 Health Check Results:"
echo "======================="

# Check if container is running
if docker ps | grep -q finders-keepers-server; then
    echo "✅ Container is running"
else
    echo "❌ Container is not running"
    exit 1
fi

# Check if port is accessible
if curl -s --connect-timeout 5 http://localhost:8087 &>/dev/null; then
    echo "✅ Server is responding on port 8087"
else
    echo "⚠️  Server may not be fully ready yet (WebSocket only, no HTTP endpoint)"
fi

# Check container health
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' finders-keepers-server 2>/dev/null || echo "unknown")
echo "🔍 Container health: $HEALTH_STATUS"

if [ "$HEALTH_STATUS" = "healthy" ] || [ "$HEALTH_STATUS" = "unknown" ]; then
    echo "✅ Health check passed!"
    exit 0
else
    echo "❌ Health check failed!"
    exit 1
fi
