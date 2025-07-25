#!/bin/bash

# Simple Docker-based deployment script for Finders Keepers Server
# This script sets up and runs the server using Docker - no development environment needed!

set -e

# Configuration
IMAGE_NAME="ghcr.io/ninjapiraatti/finders-keepers-server:latest"
CONTAINER_NAME="finders-keepers-server"
HOST_PORT=8087
CONTAINER_PORT=8087

echo "🚀 Setting up Finders Keepers Server with Docker..."
echo "This will download and run the latest version of the server."
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Update system packages
echo "📦 Updating system packages..."
sudo apt update

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    
    # Install Docker using the official script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Clean up
    rm get-docker.sh
    
    echo "✅ Docker installed successfully!"
    echo "⚠️  You may need to log out and back in for Docker permissions to take effect."
    echo "   Alternatively, you can run: newgrp docker"
    echo ""
    
    # Apply group membership for current session
    newgrp docker
else
    echo "✅ Docker is already installed"
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "🔧 Installing Docker Compose..."
    
    # Download Docker Compose
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo "✅ Docker Compose installed successfully!"
else
    echo "✅ Docker Compose is already installed"
fi

# Setup firewall rules (if ufw is enabled)
if sudo ufw status | grep -q "Status: active"; then
    echo "🔥 Configuring firewall..."
    sudo ufw allow ${HOST_PORT}/tcp comment "Finders Keepers WebSocket Server"
fi

# Stop and remove existing container if it exists
echo "🛑 Stopping any existing containers..."
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

# Create application directory for data persistence
echo "📁 Creating application directory..."
sudo mkdir -p /opt/finders-keepers/{data,logs,config}
sudo chown -R $USER:$USER /opt/finders-keepers

# Create docker-compose.yml for easy management
echo "📝 Creating Docker Compose configuration..."
cat > /opt/finders-keepers/docker-compose.yml << EOF
version: '3.8'

services:
  finders-keepers-server:
    image: ${IMAGE_NAME}
    container_name: ${CONTAINER_NAME}
    ports:
      - "${HOST_PORT}:${CONTAINER_PORT}"
    environment:
      - RUST_LOG=info
      - RUST_BACKTRACE=1
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    healthcheck:
      test: ["CMD", "sh", "-c", "netstat -tuln | grep :${CONTAINER_PORT} || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - finders-keepers

networks:
  finders-keepers:
    driver: bridge
EOF

# Create systemd service for auto-start
echo "⚙️  Setting up systemd service..."
sudo tee /etc/systemd/system/finders-keepers-docker.service > /dev/null << EOF
[Unit]
Description=Finders Keepers Server (Docker)
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/finders-keepers
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Create management scripts
echo "📝 Creating management scripts..."

# Start script
cat > /opt/finders-keepers/start.sh << 'EOF'
#!/bin/bash
cd /opt/finders-keepers
docker-compose up -d
echo "✅ Finders Keepers Server started!"
echo "🌐 Server is running on http://localhost:8087"
EOF

# Stop script
cat > /opt/finders-keepers/stop.sh << 'EOF'
#!/bin/bash
cd /opt/finders-keepers
docker-compose down
echo "🛑 Finders Keepers Server stopped!"
EOF

# Update script
cat > /opt/finders-keepers/update.sh << 'EOF'
#!/bin/bash
echo "🔄 Updating Finders Keepers Server..."
cd /opt/finders-keepers
docker-compose pull
docker-compose up -d
echo "✅ Server updated to latest version!"
EOF

# Status script
cat > /opt/finders-keepers/status.sh << 'EOF'
#!/bin/bash
cd /opt/finders-keepers
echo "📊 Finders Keepers Server Status:"
echo "=================================="
docker-compose ps
echo ""
echo "📋 Container logs (last 20 lines):"
echo "=================================="
docker-compose logs --tail=20
EOF

# Health check script
cat > /opt/finders-keepers/health-check.sh << 'EOF'
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
EOF

# Make scripts executable
chmod +x /opt/finders-keepers/*.sh

# Enable and start the service
echo "🔧 Enabling systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable finders-keepers-docker

# Pull and start the server
echo "📥 Downloading and starting Finders Keepers Server..."
cd /opt/finders-keepers

# Pull the latest image
docker-compose pull

# Start the service
docker-compose up -d

# Wait a moment for the service to start
echo "⏳ Waiting for server to start..."
sleep 10

# Run health check
if /opt/finders-keepers/health-check.sh; then
    echo ""
    echo "🎉 Setup complete! Finders Keepers Server is running!"
    echo ""
    echo "📋 Management Commands:"
    echo "======================"
    echo "Start:         /opt/finders-keepers/start.sh"
    echo "Stop:          /opt/finders-keepers/stop.sh"
    echo "Status:        /opt/finders-keepers/status.sh"
    echo "Update:        /opt/finders-keepers/update.sh"
    echo "Health Check:  /opt/finders-keepers/health-check.sh"
    echo ""
    echo "🌐 Server Info:"
    echo "==============="
    echo "WebSocket URL: ws://$(curl -s ifconfig.me || echo 'YOUR_SERVER_IP'):8087"
    echo "Local URL:     ws://localhost:8087"
    echo ""
    echo "📁 Files:"
    echo "========="
    echo "Configuration: /opt/finders-keepers/docker-compose.yml"
    echo "Logs:          /opt/finders-keepers/logs/"
    echo "Data:          /opt/finders-keepers/data/"
    echo ""
    echo "🔄 Auto-start:"
    echo "=============="
    echo "The server will automatically start on system boot."
    echo "To disable: sudo systemctl disable finders-keepers-docker"
    echo ""
    echo "📊 Monitor logs with:"
    echo "docker-compose -f /opt/finders-keepers/docker-compose.yml logs -f"
else
    echo ""
    echo "⚠️  Setup completed but the server may not be fully ready yet."
    echo "Check the status with: /opt/finders-keepers/status.sh"
    echo "View logs with: docker-compose -f /opt/finders-keepers/docker-compose.yml logs"
fi
