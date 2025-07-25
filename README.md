# Finders Keepers Multiplayer Game Server

A WebSocket-based game server built in Rust.

## 🚀 Quick Start for Server Hosting

**Just want to run the server?** Use the one-command setup:

```bash
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/deploy-docker.sh | bash
```

This will automatically install Docker, download the server, and have it running in minutes!  
📖 See [`deployment/QUICK-SETUP.md`](deployment/QUICK-SETUP.md) for detailed instructions.

**Server management commands:**
```bash
/opt/finders-keepers/start.sh        # Start server
/opt/finders-keepers/stop.sh         # Stop server  
/opt/finders-keepers/status.sh       # Check status
/opt/finders-keepers/update.sh       # Update to latest
/opt/finders-keepers/health-check.sh # Health check
```

**Get server info:**
```bash
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/server-info.sh | bash
```

**Debug connections:**
```bash
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/debug-connection.sh | bash
```

## Features

- Real-time multiplayer support via WebSockets
- Player join/leave handling
- Position synchronization
- Broadcast messaging to all connected clients
- Simple JSON-based message protocol
- Unity-compatible WebSocket interface
- **Automated Testing** and Security Auditing
- **Docker Deployment** with auto-updates
- **One-Command Setup** for any Ubuntu server

## Development Setup

### Running the Server Locally

1. Clone this repository
2. Set up development environment (optional but recommended):
   ```bash
   ./setup-hooks.sh  # Install git hooks for security checks
   ```
3. Run the server:
   ```bash
   cargo run
   ```
4. Server will start on `ws://127.0.0.1:8087`

### Using Docker

1. Build and run with Docker Compose:
   ```bash
   docker-compose up --build
   ```
2. Or build manually:
   ```bash
   docker build -t finders-keepers-server .
   docker run -p 8087:8087 finders-keepers-server
   ```

### Production Deployment

The easiest way to deploy is using our Docker-based deployment:

**Quick Setup**: See [`deployment/QUICK-SETUP.md`](deployment/QUICK-SETUP.md) for detailed instructions.

**One-Command Deploy**:
```bash
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/deploy-docker.sh | bash
```

Updates are automatic - just run `/opt/finders-keepers/update.sh` to get the latest version!

### Testing the Server

Open `test_client.html` in a web browser to test the server with a simple HTML client:
- Enter a player name and click "Connect"
- Use WASD or arrow keys to move around
- Open multiple browser tabs to test multiple players

## Development

### Running Tests
```bash
cargo test
```

### Code Formatting
```bash
cargo fmt
```

### Linting
```bash
cargo clippy
```

### Security Audit
```bash
cargo install cargo-audit
cargo audit
```

## CI Pipeline

The GitHub Actions pipeline includes:

- ✅ **Automated Testing**: Unit tests, formatting, and linting
- 🔒 **Security Auditing**: Dependency vulnerability scanning
- 🏗️ **Release Building**: Optimized production builds
- � **Docker Images**: Multi-platform images pushed to GitHub Container Registry

### Pipeline Triggers
- **Pull Requests**: Run tests and security checks
- **Main Branch**: Full pipeline including Docker image building
- **Manual**: Can be triggered manually for rebuilds

### How It Works
1. **Code changes** pushed to main branch
2. **Tests run** automatically (formatting, linting, unit tests, security audit)
3. **Docker image** built for multiple platforms (AMD64/ARM64)
4. **Image pushed** to GitHub Container Registry
5. **Deployments update** automatically when you run `/opt/finders-keepers/update.sh`

## Architecture

- **WebSocket Server**: Handles client connections and message routing
- **Game State**: Thread-safe HashMap storing player information
- **Broadcast System**: Efficient message distribution to all connected clients
- **JSON Protocol**: Simple, human-readable message format