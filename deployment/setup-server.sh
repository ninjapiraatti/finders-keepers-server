#!/bin/bash

# Server setup script for Finders Keepers Server
# Run this script on your Ubuntu server to set up the deployment environment

set -e

echo "🚀 Setting up Finders Keepers Server deployment environment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "📋 Installing required packages..."
sudo apt install -y curl wget unzip systemd net-tools

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /opt/finders-keepers
sudo mkdir -p /var/log/finders-keepers

# Create www-data user if it doesn't exist and set permissions
echo "👤 Setting up user and permissions..."
id -u www-data &>/dev/null || sudo useradd -r -s /bin/false www-data
sudo chown -R www-data:www-data /opt/finders-keepers
sudo chown -R www-data:www-data /var/log/finders-keepers

# Copy and enable systemd service
echo "⚙️  Setting up systemd service..."
sudo cp finders-keepers.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable finders-keepers

# Setup log rotation
echo "📝 Setting up log rotation..."
sudo tee /etc/logrotate.d/finders-keepers > /dev/null << EOF
/var/log/finders-keepers/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
}
EOF

# Setup firewall rules (if ufw is enabled)
if sudo ufw status | grep -q "Status: active"; then
    echo "🔥 Configuring firewall..."
    sudo ufw allow 8087/tcp comment "Finders Keepers WebSocket Server"
fi

# Create a simple health check script
echo "🏥 Creating health check script..."
sudo tee /opt/finders-keepers/health-check.sh > /dev/null << 'EOF'
#!/bin/bash
if netstat -tuln | grep -q ":8087 "; then
    echo "OK: Service is listening on port 8087"
    exit 0
else
    echo "ERROR: Service is not listening on port 8087"
    exit 1
fi
EOF
sudo chmod +x /opt/finders-keepers/health-check.sh
sudo chown www-data:www-data /opt/finders-keepers/health-check.sh

echo "✅ Server setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Set up GitHub secrets for deployment:"
echo "   - SERVER_HOST: Your server's IP address or domain"
echo "   - SERVER_USER: Your SSH username"
echo "   - SERVER_SSH_KEY: Your private SSH key"
echo "   - SERVER_PORT: SSH port (optional, defaults to 22)"
echo ""
echo "2. Push your code to the main branch to trigger deployment"
echo ""
echo "3. Monitor the service with:"
echo "   sudo systemctl status finders-keepers"
echo "   sudo journalctl -u finders-keepers -f"
echo ""
echo "4. Test health check:"
echo "   /opt/finders-keepers/health-check.sh"
