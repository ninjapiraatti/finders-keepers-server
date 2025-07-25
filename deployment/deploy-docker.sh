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
sudo mkdir -p /opt/finders-keepers-server/{data,logs,config}
sudo chown -R $USER:$USER /opt/finders-keepers-server

# Create docker-compose.yml for easy management
echo "📝 Creating Docker Compose configuration..."
cat > /opt/finders-keepers-server/docker-compose.yml << EOF
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
WorkingDirectory=/opt/finders-keepers-server
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Copy management scripts
echo "📝 Installing management scripts..."

# Download and install management scripts from the repository
SCRIPT_BASE_URL="https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment"

curl -fsSL "${SCRIPT_BASE_URL}/start.sh" -o /opt/finders-keepers-server/start.sh
curl -fsSL "${SCRIPT_BASE_URL}/stop.sh" -o /opt/finders-keepers-server/stop.sh
curl -fsSL "${SCRIPT_BASE_URL}/update.sh" -o /opt/finders-keepers-server/update.sh
curl -fsSL "${SCRIPT_BASE_URL}/status.sh" -o /opt/finders-keepers-server/status.sh
curl -fsSL "${SCRIPT_BASE_URL}/health-check.sh" -o /opt/finders-keepers-server/health-check.sh

# Make scripts executable
chmod +x /opt/finders-keepers-server/*.sh

echo "✅ Management scripts installed successfully!"

# Enable and start the service
echo "🔧 Enabling systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable finders-keepers-docker

# Pull and start the server
echo "📥 Downloading and starting Finders Keepers Server..."
cd /opt/finders-keepers-server

# Pull the latest image
docker-compose pull

# Start the service
docker-compose up -d

# Wait a moment for the service to start
echo "⏳ Waiting for server to start..."
sleep 10

# Run health check
if /opt/finders-keepers-server/health-check.sh; then
    echo ""
    echo "🎉 Setup complete! Finders Keepers Server is running!"
    echo ""
    echo "📋 Management Commands:"
    echo "======================"
    echo "Start:         /opt/finders-keepers-server/start.sh"
    echo "Stop:          /opt/finders-keepers-server/stop.sh"
    echo "Status:        /opt/finders-keepers-server/status.sh"
    echo "Update:        /opt/finders-keepers-server/update.sh"
    echo "Health Check:  /opt/finders-keepers-server/health-check.sh"
    echo ""
    echo "🌐 Server Info:"
    echo "==============="
    echo "WebSocket URL: ws://$(curl -s ifconfig.me || echo 'YOUR_SERVER_IP'):8087"
    echo "Local URL:     ws://localhost:8087"
    echo ""
    echo "📁 Files:"
    echo "========="
    echo "Configuration: /opt/finders-keepers-server/docker-compose.yml"
    echo "Logs:          /opt/finders-keepers-server/logs/"
    echo "Data:          /opt/finders-keepers-server/data/"
    echo ""
    echo "🔄 Auto-start:"
    echo "=============="
    echo "The server will automatically start on system boot."
    echo "To disable: sudo systemctl disable finders-keepers-docker"
    echo ""
    echo "📊 Monitor logs with:"
    echo "docker-compose -f /opt/finders-keepers-server/docker-compose.yml logs -f"
else
    echo ""
    echo "⚠️  Setup completed but the server may not be fully ready yet."
    echo "Check the status with: /opt/finders-keepers-server/status.sh"
    echo "View logs with: docker-compose -f /opt/finders-keepers-server/docker-compose.yml logs"
fi
