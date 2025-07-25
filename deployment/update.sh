#!/bin/bash
echo "🔄 Updating Finders Keepers Server..."
cd /opt/finders-keepers

# Stop the current container
echo "🛑 Stopping current server..."
docker-compose down

# Force pull the latest image (bypass cache)
echo "📥 Downloading latest image..."
docker-compose pull --ignore-pull-failures

# Alternative: Use docker pull directly to be more explicit
IMAGE_NAME=$(grep "image:" docker-compose.yml | awk '{print $2}' | head -1)
if [ ! -z "$IMAGE_NAME" ]; then
    echo "📦 Force pulling image: $IMAGE_NAME"
    docker pull --platform linux/amd64 "$IMAGE_NAME"
fi

# Remove old containers and images to free space
echo "🧹 Cleaning up old containers and images..."
docker container prune -f
docker image prune -f

# Start with the new image
echo "🚀 Starting updated server..."
docker-compose up -d

# Wait a moment for startup
echo "⏳ Waiting for server to start..."
sleep 5

# Show the status
echo "📊 Current status:"
docker-compose ps

echo ""
echo "✅ Server updated to latest version!"
echo "🔍 Check logs with: docker-compose logs -f"
