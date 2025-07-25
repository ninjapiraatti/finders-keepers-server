# Quick Server Setup - Just Run the Game Server!

This guide is for users who just want to run the Finders Keepers game server without any development setup. Perfect for game server hosting or personal use.

## 🚀 One-Command Setup

If you have an Ubuntu server and just want to run the game server, this is all you need:

```bash
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/deploy-docker.sh | bash
```

That's it! The script will:
- ✅ Install Docker automatically
- ✅ Download the latest server image
- ✅ Configure firewall rules
- ✅ Set up auto-start on boot
- ✅ Create management scripts
- ✅ Start the server immediately

## 📋 What You Get

After running the script, you'll have:

- **🌐 Running Game Server** on port 8087
- **🔄 Auto-restart** on system reboot
- **📊 Management Scripts** for easy control
- **🏥 Health Monitoring** built-in
- **📝 Logging** with automatic rotation

## 🎮 Connect to Your Server

Once setup is complete, players can connect to:
```
ws://YOUR_SERVER_IP:8087
```

Replace `YOUR_SERVER_IP` with your server's actual IP address.

## 🛠️ Managing Your Server

The setup creates easy-to-use management scripts:

### Start the Server
```bash
/opt/finders-keepers/start.sh
```

### Stop the Server
```bash
/opt/finders-keepers/stop.sh
```

### Check Status
```bash
/opt/finders-keepers/status.sh
```

### Update to Latest Version
```bash
/opt/finders-keepers/update.sh
```

### Health Check
```bash
/opt/finders-keepers/health-check.sh
```

## 📊 Monitoring

### View Live Logs
```bash
cd /opt/finders-keepers
docker-compose logs -f
```

### Check Server Status
```bash
/opt/finders-keepers/status.sh
```

### System Service Status
```bash
sudo systemctl status finders-keepers-docker
```

## 🔧 Configuration

The server configuration is stored in:
```
/opt/finders-keepers/docker-compose.yml
```

You can edit this file to:
- Change the port number
- Adjust environment variables
- Modify restart policies
- Add volume mounts

After making changes, restart the server:
```bash
/opt/finders-keepers/stop.sh
/opt/finders-keepers/start.sh
```

## 🚨 Troubleshooting

### Server Won't Start
1. Check Docker is running:
   ```bash
   sudo systemctl status docker
   ```

2. Check the logs:
   ```bash
   /opt/finders-keepers/status.sh
   ```

3. Try restarting:
   ```bash
   /opt/finders-keepers/stop.sh
   /opt/finders-keepers/start.sh
   ```

### Can't Connect from Outside
1. Check firewall:
   ```bash
   sudo ufw status
   ```

2. Ensure port 8087 is allowed:
   ```bash
   sudo ufw allow 8087/tcp
   ```

3. Check if server is listening:
   ```bash
   netstat -tuln | grep :8087
   ```

### Performance Issues
1. Check system resources:
   ```bash
   docker stats finders-keepers-server
   ```

2. View detailed logs:
   ```bash
   cd /opt/finders-keepers
   docker-compose logs --tail=100
   ```

## 🔄 Updating

The server will automatically use the latest stable version. To manually update:

```bash
/opt/finders-keepers/update.sh
```

This will:
- Download the latest version
- Restart with zero downtime
- Keep all your data intact

## 📁 File Locations

- **Configuration**: `/opt/finders-keepers/docker-compose.yml`
- **Management Scripts**: `/opt/finders-keepers/*.sh`
- **Logs**: `/opt/finders-keepers/logs/`
- **Data**: `/opt/finders-keepers/data/`
- **System Service**: `/etc/systemd/system/finders-keepers-docker.service`

## 🆘 Getting Help

If you encounter issues:

1. **Check the logs** first:
   ```bash
   /opt/finders-keepers/status.sh
   ```

2. **Run health check**:
   ```bash
   /opt/finders-keepers/health-check.sh
   ```

3. **Check system status**:
   ```bash
   sudo systemctl status finders-keepers-docker
   ```

4. **Restart everything**:
   ```bash
   sudo systemctl restart docker
   /opt/finders-keepers/start.sh
   ```

## 🔐 Security Notes

- The server runs in a Docker container for isolation
- Only port 8087 is exposed
- The container runs as non-root user
- Automatic security updates are recommended:
  ```bash
  sudo apt install unattended-upgrades
  sudo dpkg-reconfigure -plow unattended-upgrades
  ```

## 📞 Support

For technical support or questions about the game server:
- Check the main repository: https://github.com/ninjapiraatti/finders-keepers-server
- Open an issue for bugs or feature requests

---

**That's it!** Your Finders Keepers game server should now be running and ready for players to connect. 🎮
