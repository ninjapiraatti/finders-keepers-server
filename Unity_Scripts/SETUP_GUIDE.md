# Unity Integration Setup Guide

## Prerequisites

1. **Unity 2022.3 LTS or newer** (recommended)
2. **NativeWebSocket package** installed
3. **TextMeshPro** (usually included with Unity)
4. **Newtonsoft.Json** (should be included by default in modern Unity)

## Step-by-Step Setup

### 1. Install NativeWebSocket Package

1. Open Unity Package Manager (**Window → Package Manager**)
2. Click the **+** button in top-left
3. Select **"Add package from git URL"**
4. Enter: `https://github.com/endel/NativeWebSocket.git#upm`
5. Click **Add**

### 2. Create Your Player Prefab

1. Create a new **GameObject** in your scene
2. Add a **Capsule** or **Cube** as a child (for visual representation)
3. Add the provided scripts:
   - **NetworkPlayer.cs**
   - **PlayerInputController.cs**
4. Create a **TextMeshPro** object as a child for the player name (position it above the player)
5. Save as a prefab in your **Assets/Prefabs** folder

### 3. Setup the Scene

1. Create an empty **GameObject** and name it "NetworkManager"
2. Add the **GameNetworkManager.cs** script to it
3. Assign your player prefab to the **Player Prefab** field
4. Set a spawn point transform (or leave empty to spawn at origin)

### 4. Create the UI (Optional but Recommended)

1. Create a **Canvas** in your scene (Right-click → UI → Canvas)
2. Create the connection UI:
   - Add a **Panel** for connection screen
   - Add **Input Fields** for player name and server URL
   - Add **Buttons** for Connect/Disconnect
   - Add **Text** for status display
3. Create game UI:
   - Add another **Panel** for in-game UI
   - Add **Text** elements for player count, instructions, etc.
4. Add the **GameUIManager.cs** script to a **GameObject**
5. Wire up all the UI elements in the inspector

### 5. Configure the Network Manager

In the **GameNetworkManager** component:
- **Server URL**: `ws://127.0.0.1:8080` (or your server's address)
- **Player Name**: Default name for your player
- **Player Prefab**: Your created player prefab
- **Spawn Point**: Where players should spawn (optional)
- **Enable Debug Logs**: Check for debugging

### 6. Test the Connection

1. Make sure your Rust server is running (`cargo run`)
2. Press Play in Unity
3. Enter a player name and click Connect
4. You should see connection logs and be able to move with WASD
5. Open multiple Unity instances or the web test client to see multiplayer in action

## Script Breakdown

### GameNetworkManager.cs
- Handles WebSocket connection to server
- Manages player spawning and cleanup
- Sends/receives messages to/from server
- Provides events for other scripts to listen to

### PlayerInputController.cs
- Handles local player input (WASD movement)
- Sends position updates to server
- Includes smoothing and throttling for network efficiency

### NetworkPlayer.cs
- Represents a player in the game world
- Handles visual differences between local and remote players
- Provides smooth movement for remote players
- Displays player names

### GameUIManager.cs
- Manages connection and game UI
- Provides debug information
- Handles connection/disconnection events

## Customization Tips

### Movement System
- Modify `PlayerInputController.cs` to change movement speed, keys, or add jumping
- Add physics by using Rigidbody instead of direct transform manipulation

### Visual Improvements
- Add animations for player movement
- Implement better interpolation for smooth remote player movement
- Add particle effects or trails

### Game Features
- Add chat system (extend the message protocol)
- Implement game boundaries
- Add collectible items or objectives
- Create different player classes or abilities

### Network Optimization
- Implement client-side prediction
- Add lag compensation
- Use delta compression for position updates
- Add connection quality indicators

## Troubleshooting

### Common Issues

1. **"NativeWebSocket not found"**
   - Make sure the package is installed correctly
   - Check Unity Console for any import errors

2. **"Connection failed"**
   - Verify the server is running (`cargo run`)
   - Check the server URL is correct
   - Ensure firewall isn't blocking the connection

3. **Players not visible**
   - Check that Player Prefab is assigned
   - Verify the spawn point is reasonable
   - Look for errors in Unity Console

4. **Movement feels laggy**
   - Adjust `smoothTime` in PlayerInputController
   - Modify `sendInterval` for more frequent updates
   - Check network latency

### Debug Features

- Press **F1** in-game to toggle debug panel
- Check Unity Console for detailed logs
- Use the web test client alongside Unity for comparison

## Next Steps

Once you have basic multiplayer working:

1. **Add Authentication**: Implement proper login system
2. **Game Rooms**: Support multiple game sessions
3. **Persistence**: Save player progress
4. **Game Logic**: Add your specific game mechanics
5. **Security**: Validate inputs and prevent cheating
6. **Mobile Support**: Test and optimize for mobile platforms
7. **Build and Deploy**: Create builds for different platforms

## Performance Notes

- The current implementation is suitable for 10-50 concurrent players
- For larger player counts, consider implementing spatial partitioning
- Monitor memory usage, especially for long-running sessions
- Test with simulated network conditions (latency, packet loss)
