# Finders Keepers Multiplayer Game Server

A WebSocket-based game server built in Rust for handling multiplayer game sessions. Supports real-time player position updates and game state synchronization.

## Features

- Real-time multiplayer support via WebSockets
- Player join/leave handling
- Position synchronization
- Broadcast messaging to all connected clients
- Simple JSON-based message protocol
- Unity-compatible WebSocket interface

## Quick Start

### Running the Server

1. Clone this repository
2. Run the server:
   ```bash
   cargo run
   ```
3. Server will start on `ws://127.0.0.1:8080`

### Testing the Server

Open `test_client.html` in a web browser to test the server with a simple HTML client:
- Enter a player name and click "Connect"
- Use WASD or arrow keys to move around
- Open multiple browser tabs to test multiple players

## Message Protocol

### Client to Server Messages

#### Join Game
```json
{
  "type": "Join",
  "player_name": "PlayerName"
}
```

#### Update Position
```json
{
  "type": "UpdatePosition",
  "x": 100.5,
  "y": 0.0,
  "z": 200.3
}
```

#### Leave Game
```json
{
  "type": "Leave"
}
```

### Server to Client Messages

#### Game State (sent on join)
```json
{
  "type": "GameState",
  "players": [
    {
      "id": "uuid-string",
      "name": "PlayerName",
      "x": 100.5,
      "y": 0.0,
      "z": 200.3
    }
  ]
}
```

#### Player Joined
```json
{
  "type": "PlayerJoined",
  "player_id": "uuid-string",
  "player_name": "PlayerName",
  "x": 0.0,
  "y": 0.0,
  "z": 0.0
}
```

#### Player Moved
```json
{
  "type": "PlayerMoved",
  "player_id": "uuid-string",
  "x": 100.5,
  "y": 0.0,
  "z": 200.3
}
```

#### Player Left
```json
{
  "type": "PlayerLeft",
  "player_id": "uuid-string"
}
```

#### Error
```json
{
  "type": "Error",
  "message": "Error description"
}
```

## Unity Integration

### Setup WebSocket Connection

1. Install a WebSocket library for Unity (e.g., NativeWebSocket or WebSocketSharp)
2. Connect to the server:

```csharp
using UnityEngine;
using NativeWebSocket;
using System;

public class GameNetworkManager : MonoBehaviour
{
    private WebSocket websocket;
    
    async void Start()
    {
        websocket = new WebSocket("ws://127.0.0.1:8080");
        
        websocket.OnOpen += () => {
            Debug.Log("Connected to server");
            JoinGame("PlayerName");
        };
        
        websocket.OnMessage += (bytes) => {
            var message = System.Text.Encoding.UTF8.GetString(bytes);
            HandleServerMessage(message);
        };
        
        await websocket.Connect();
    }
    
    void Update()
    {
        #if !UNITY_WEBGL || UNITY_EDITOR
        websocket?.DispatchMessageQueue();
        #endif
    }
    
    private async void JoinGame(string playerName)
    {
        var joinMessage = new {
            type = "Join",
            player_name = playerName
        };
        
        await websocket.SendText(JsonUtility.ToJson(joinMessage));
    }
    
    public async void SendPositionUpdate(Vector3 position)
    {
        var moveMessage = new {
            type = "UpdatePosition",
            x = position.x,
            y = position.y,
            z = position.z
        };
        
        await websocket.SendText(JsonUtility.ToJson(moveMessage));
    }
    
    private void HandleServerMessage(string message)
    {
        // Parse and handle server messages
        Debug.Log($"Server message: {message}");
        // Add your game logic here
    }
    
    private async void OnApplicationQuit()
    {
        await websocket.Close();
    }
}
```

### Message Classes for Unity

```csharp
[Serializable]
public class Player
{
    public string id;
    public string name;
    public float x;
    public float y;
    public float z;
}

[Serializable]
public class ServerMessage
{
    public string type;
}

[Serializable]
public class GameStateMessage : ServerMessage
{
    public Player[] players;
}

[Serializable]
public class PlayerJoinedMessage : ServerMessage
{
    public string player_id;
    public string player_name;
    public float x;
    public float y;
    public float z;
}

[Serializable]
public class PlayerMovedMessage : ServerMessage
{
    public string player_id;
    public float x;
    public float y;
    public float z;
}

[Serializable]
public class PlayerLeftMessage : ServerMessage
{
    public string player_id;
}
```

## Architecture

- **WebSocket Server**: Handles client connections and message routing
- **Game State**: Thread-safe HashMap storing player information
- **Broadcast System**: Efficient message distribution to all connected clients
- **JSON Protocol**: Simple, human-readable message format

## Next Steps

1. **Authentication**: Add proper player authentication
2. **Game Rooms**: Support multiple game rooms/lobbies
3. **Persistence**: Add database integration for player data
4. **Security**: Input validation and cheat prevention
5. **Scaling**: Load balancing and horizontal scaling
6. **Game Logic**: Add game-specific features (items, NPCs, etc.)

## Dependencies

- `tokio` - Async runtime
- `tokio-tungstenite` - WebSocket support
- `serde` - JSON serialization
- `uuid` - Unique player IDs
- `tracing` - Logging

## License

MIT License