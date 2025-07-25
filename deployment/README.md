# Deployment Guide

This guide explains how to deploy the Finders Keepers WebSocket Server. Choose the deployment method that best fits your needs:

## 🚀 Option 1: Quick Docker Deployment (Recommended for End Users)

**Perfect for:** Game server hosting, personal use, quick setup

This is the easiest way to get the server running. No development environment needed!

### One-Command Setup
```bash
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/deploy-docker.sh | bash
```

**What this does:**
- ✅ Installs Docker automatically
- ✅ Downloads the latest pre-built server image
- ✅ Configures firewall and auto-start
- ✅ Creates management scripts
- ✅ Starts the server immediately

📖 **Detailed instructions:** See [`QUICK-SETUP.md`](QUICK-SETUP.md)

### Managing Your Docker Deployment
```bash
# Start the server
/opt/finders-keepers/start.sh

# Stop the server
/opt/finders-keepers/stop.sh

# Check status
/opt/finders-keepers/status.sh

# Update to latest version
/opt/finders-keepers/update.sh

# Health check
/opt/finders-keepers/health-check.sh
```

---

# Deployment Guide

This guide explains how to deploy the Finders Keepers WebSocket Server using Docker.

## � Quick Docker Deployment (Recommended)

**Perfect for:** Everyone! Game server hosting, personal use, development

This is the easiest way to get the server running. No development environment needed!

### One-Command Setup
```bash
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/deploy-docker.sh | bash
```

**What this does:**
- ✅ Installs Docker automatically
- ✅ Downloads the latest pre-built server image from GitHub Container Registry
- ✅ Configures firewall and auto-start
- ✅ Creates management scripts
- ✅ Starts the server immediately

📖 **Detailed instructions:** See [`QUICK-SETUP.md`](QUICK-SETUP.md)

### Managing Your Docker Deployment
```bash
# Start the server
/opt/finders-keepers/start.sh

# Stop the server
/opt/finders-keepers/stop.sh

# Check status
/opt/finders-keepers/status.sh

# Update to latest version
/opt/finders-keepers/update.sh

# Health check
/opt/finders-keepers/health-check.sh
```

### How Updates Work

The server automatically pulls the latest Docker image built by our CI pipeline:

1. **Code changes** are pushed to the main branch
2. **GitHub Actions** automatically builds and tests the code
3. **Docker image** is built and pushed to GitHub Container Registry
4. **Your server** can update by running: `/opt/finders-keepers/update.sh`

---

## 🛠️ Development Workflow

If you're contributing to the project or want to build custom versions:

### Local Development
```bash
# Clone the repository
git clone https://github.com/ninjapiraatti/finders-keepers-server.git
cd finders-keepers-server

# Run tests
cargo test

# Run locally
cargo run

# Build with Docker
docker build -t finders-keepers-server .
docker run -p 8087:8087 finders-keepers-server
```

### CI Pipeline

The project includes automated testing and building:

- **🧪 Tests**: Code formatting, linting, unit tests, security audits
- **🏗️ Build**: Release builds for verification
- **🐳 Docker**: Multi-platform images pushed to GitHub Container Registry

### Making Changes

1. **Fork** the repository
2. **Make changes** and test locally
3. **Create pull request** - this triggers tests
4. **Merge to main** - this builds and pushes new Docker images
5. **Update deployments** with `/opt/finders-keepers/update.sh`

---

## 📋 Prerequisites

### For Quick Setup
- Ubuntu server (18.04+)
- Internet connection
- sudo privileges

### For Development
- Rust 1.75+
- Docker (optional)
- Git

---

## 🌐 Network Configuration

The server runs on **port 8087** by default. Players connect using:
```
ws://YOUR_SERVER_IP:8087
```

### Firewall Configuration
The setup script automatically configures UFW if it's enabled:
```bash
sudo ufw allow 8087/tcp
```

### Custom Port
To use a different port, edit `/opt/finders-keepers/docker-compose.yml`:
```yaml
ports:
  - "9000:8087"  # External:Internal
```

Then restart: `/opt/finders-keepers/stop.sh && /opt/finders-keepers/start.sh`

---

## 📊 Monitoring and Troubleshooting

### Check Server Status
```bash
/opt/finders-keepers/status.sh
```

### View Logs
```bash
# Real-time logs
cd /opt/finders-keepers
docker-compose logs -f

# Last 50 lines
docker-compose logs --tail=50
```

### Health Check
```bash
/opt/finders-keepers/health-check.sh
```

### Common Issues

**Server won't start:**
```bash
# Check Docker
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Try starting again
/opt/finders-keepers/start.sh
```

**Can't connect from outside:**
```bash
# Check firewall
sudo ufw status

# Check if port is listening
netstat -tuln | grep :8087

# Check container
docker ps | grep finders-keepers
```

### Performance Monitoring
```bash
# Container resource usage
docker stats finders-keepers-server

# System resources
htop
# or
docker stats
```

---

## 🔄 Backup and Recovery

### Configuration Backup
```bash
# Backup configuration
cp /opt/finders-keepers/docker-compose.yml ~/finders-keepers-backup.yml
```

### Data Backup
```bash
# Backup persistent data (if any)
tar -czf ~/finders-keepers-data-backup.tar.gz /opt/finders-keepers/data/
```

### Recovery
```bash
# Restore configuration
cp ~/finders-keepers-backup.yml /opt/finders-keepers/docker-compose.yml

# Restart with restored config
/opt/finders-keepers/stop.sh
/opt/finders-keepers/start.sh
```

---

## 🔐 Security Best Practices

### Automatic Updates
Enable unattended upgrades for security patches:
```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Docker Security
The container runs with security hardening:
- Non-root user
- Read-only filesystem (where possible)
- Limited capabilities
- Health checks

### Server Security
- Keep Docker updated: `sudo apt update && sudo apt upgrade docker-ce`
- Monitor logs regularly
- Use strong SSH keys
- Consider fail2ban for SSH protection

---

## 📞 Support

### Getting Help
1. **Check logs** first: `/opt/finders-keepers/status.sh`
2. **Run health check**: `/opt/finders-keepers/health-check.sh`
3. **Check GitHub issues**: https://github.com/ninjapiraatti/finders-keepers-server/issues
4. **Create new issue** with logs and system info

### Contributing
- Fork the repository
- Create feature branch
- Add tests for new features
- Submit pull request

---

## 📁 File Locations

- **Docker Compose**: `/opt/finders-keepers/docker-compose.yml`
- **Management Scripts**: `/opt/finders-keepers/*.sh`
- **Logs**: `/opt/finders-keepers/logs/`
- **Data**: `/opt/finders-keepers/data/`
- **Systemd Service**: `/etc/systemd/system/finders-keepers-docker.service`

---

The deployment is now simplified to use Docker for everything, with automatic image updates from the CI pipeline! 🚀

- Ubuntu server with SSH access
- GitHub repository with admin access
- Domain name or static IP address (optional but recommended)

## Server Setup

1. **Copy deployment files to your server:**
   ```bash
   scp -r deployment/ your-user@your-server-ip:/tmp/
   ```

2. **Run the setup script on your server:**
   ```bash
   ssh your-user@your-server-ip
   cd /tmp/deployment
   sudo ./setup-server.sh
   ```

## GitHub Secrets Configuration

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add these secrets:

### Required Secrets

- **`SERVER_HOST`**: Your server's IP address or domain name
  - Example: `192.168.1.100` or `your-domain.com`

- **`SERVER_USER`**: SSH username for your server
  - Example: `ubuntu`, `root`, or your custom user

- **`SERVER_SSH_KEY`**: Your private SSH key
  - Generate with: `ssh-keygen -t ed25519 -C "github-actions"`
  - Copy the **private key** content (the one without `.pub` extension)

### Optional Secrets

- **`SERVER_PORT`**: SSH port (defaults to 22 if not set)
  - Example: `2222` if you use a custom SSH port

## Pipeline Overview

The CI/CD pipeline includes these stages:

### 1. **Test Suite** (runs on all pushes and PRs)
- Code formatting check (`cargo fmt`)
- Linting with Clippy (`cargo clippy`)
- Unit tests (`cargo test`)
- Build verification

### 2. **Security Audit** (runs on all pushes and PRs)
- Dependency vulnerability scanning with `cargo audit`

### 3. **Build Release** (runs only on main branch)
- Creates optimized release build
- Uploads binary as artifact

### 4. **Deploy** (runs only on main branch, requires manual approval)
- Downloads build artifact
- Stops running service
- Backs up current binary
- Deploys new binary
- Starts service
- Performs health check

## Environment Protection

The deployment job uses GitHub's environment protection feature:

1. Go to Repository Settings → Environments
2. Create an environment named `production`
3. Add protection rules:
   - Required reviewers (recommended)
   - Wait timer (optional)
   - Deployment branches (restrict to `main`)

## Monitoring and Troubleshooting

### Check service status:
```bash
sudo systemctl status finders-keepers
```

### View logs:
```bash
# Recent logs
sudo journalctl -u finders-keepers -n 50

# Follow logs in real-time
sudo journalctl -u finders-keepers -f
```

### Manual service control:
```bash
# Start
sudo systemctl start finders-keepers

# Stop
sudo systemctl stop finders-keepers

# Restart
sudo systemctl restart finders-keepers

# Reload service file after changes
sudo systemctl daemon-reload
```

### Health check:
```bash
/opt/finders-keepers/health-check.sh
```

### Check if port is listening:
```bash
netstat -tuln | grep :8087
```

## Rollback Procedure

If a deployment fails, you can quickly rollback:

```bash
# Stop the service
sudo systemctl stop finders-keepers

# Restore previous version
sudo cp /opt/finders-keepers/finders-keepers-server.backup /opt/finders-keepers/finders-keepers-server

# Start the service
sudo systemctl start finders-keepers
```

## File Locations

- **Binary**: `/opt/finders-keepers/finders-keepers-server`
- **Service file**: `/etc/systemd/system/finders-keepers.service`
- **Logs**: `journalctl -u finders-keepers` or `/var/log/syslog`
- **Health check**: `/opt/finders-keepers/health-check.sh`

## Security Considerations

- The service runs as `www-data` user with minimal privileges
- Systemd security features are enabled (private tmp, read-only filesystem, etc.)
- Firewall rules allow only necessary port (8087)
- Log rotation is configured to prevent disk space issues

## Testing the Pipeline

1. **Push to main branch** to trigger the full pipeline
2. **Create a pull request** to test only the test and security stages
3. **Check GitHub Actions tab** for pipeline status
4. **Monitor server logs** during deployment

## Customization

### Environment Variables
Edit `/etc/systemd/system/finders-keepers.service` to add environment variables:
```ini
Environment=RUST_LOG=debug
Environment=CUSTOM_VAR=value
```

### Port Configuration
If you need to change the port, update:
1. Your Rust code in `main.rs`
2. Firewall rules: `sudo ufw allow NEW_PORT/tcp`
3. Health check script: `/opt/finders-keepers/health-check.sh`

### Service Configuration
Modify `/etc/systemd/system/finders-keepers.service` and run:
```bash
sudo systemctl daemon-reload
sudo systemctl restart finders-keepers
```
