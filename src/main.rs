use futures_util::{SinkExt, StreamExt};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::net::SocketAddr;
use std::sync::Arc;
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::{Mutex, broadcast};
use tokio_tungstenite::{accept_async, tungstenite::Message};
use tracing::{error, info};

#[cfg(test)]
mod tests;

// Message types for client-server communication
#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type")]
pub enum ClientMessage {
    Join { player_id: String, player_name: String },
    UpdatePosition { x: f32, y: f32, z: f32 },
    Leave,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type")]
pub enum ServerMessage {
    PlayerJoined {
        player_id: String,
        player_name: String,
        x: f32,
        y: f32,
        z: f32,
    },
    PlayerLeft {
        player_id: String,
    },
    PlayerMoved {
        player_id: String,
        x: f32,
        y: f32,
        z: f32,
    },
    GameState {
        players: Vec<Player>,
    },
    Error {
        message: String,
    },
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Player {
    pub id: String,
    pub name: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
}

// Game state shared between all connections
pub type GameState = Arc<Mutex<HashMap<String, Player>>>;

#[tokio::main]
async fn main() {
    // Initialize logging
    tracing_subscriber::fmt::init();

    // Create shared game state
    let game_state = Arc::new(Mutex::new(HashMap::new()));

    // Create broadcast channel for sending messages to all clients
    let (tx, _rx) = broadcast::channel(100);

    // Read bind address and port from environment variables
    let bind_address = std::env::var("BIND_ADDRESS").unwrap_or_else(|_| "0.0.0.0".to_string());
    let port = std::env::var("PORT").unwrap_or_else(|_| "8087".to_string());
    let addr = format!("{bind_address}:{port}");
    let listener = TcpListener::bind(&addr).await.expect("Failed to bind");
    info!("Finders Keepers Server listening on: {}", addr);

    while let Ok((stream, addr)) = listener.accept().await {
        let game_state = game_state.clone();
        let tx = tx.clone();

        tokio::spawn(handle_connection(stream, addr, game_state, tx));
    }
}

async fn handle_connection(
    stream: TcpStream,
    addr: SocketAddr,
    game_state: GameState,
    tx: broadcast::Sender<ServerMessage>,
) {
    info!("New connection from: {}", addr);

    let ws_stream = match accept_async(stream).await {
        Ok(ws) => ws,
        Err(e) => {
            error!("Error during WebSocket handshake: {}", e);
            return;
        }
    };

    let (mut ws_sender, mut ws_receiver) = ws_stream.split();
    let mut rx = tx.subscribe();

    // Handle incoming messages from client
    let game_state_clone = game_state.clone();
    let tx_clone = tx.clone();

    let receive_task = tokio::spawn(async move {
        let mut current_player_id: Option<String> = None;
        
        while let Some(msg) = ws_receiver.next().await {
            match msg {
                Ok(Message::Text(text)) => {
                    if let Ok(client_msg) = serde_json::from_str::<ClientMessage>(&text) {
                        current_player_id = handle_client_message(
                            client_msg,
                            current_player_id,
                            &game_state_clone,
                            &tx_clone,
                        )
                        .await;
                    }
                }
                Ok(Message::Close(_)) => {
                    info!("Client {} disconnected", addr);
                    break;
                }
                Err(e) => {
                    error!("WebSocket error: {}", e);
                    break;
                }
                _ => {}
            }
        }

        // Clean up player on disconnect
        if let Some(player_id) = current_player_id {
            let mut state = game_state_clone.lock().await;
            if state.remove(&player_id).is_some() {
                let _ = tx_clone.send(ServerMessage::PlayerLeft {
                    player_id: player_id,
                });
            }
        }
    });

    // Handle outgoing messages to client
    let send_task = tokio::spawn(async move {
        while let Ok(server_msg) = rx.recv().await {
            let msg_json = serde_json::to_string(&server_msg).unwrap();
            if ws_sender.send(Message::Text(msg_json)).await.is_err() {
                break;
            }
        }
    });

    // Wait for either task to complete
    tokio::select! {
        _ = receive_task => {},
        _ = send_task => {},
    }

    info!("Connection closed: {}", addr);
}

async fn handle_client_message(
    msg: ClientMessage,
    current_player_id: Option<String>,
    game_state: &GameState,
    tx: &broadcast::Sender<ServerMessage>,
) -> Option<String> {
    match msg {
        ClientMessage::Join { player_id, player_name } => {
            // Check if player ID is already in use
            {
                let state = game_state.lock().await;
                if state.contains_key(&player_id) {
                    let _ = tx.send(ServerMessage::Error {
                        message: format!("Player ID {} is already in use", player_id),
                    });
                    return current_player_id;
                }
            }

            let player = Player {
                id: player_id.clone(),
                name: player_name.clone(),
                x: 0.0,
                y: 0.0,
                z: 0.0,
            };

            {
                let mut state = game_state.lock().await;
                state.insert(player_id.clone(), player.clone());
            }

            // Send current game state to new player
            {
                let state = game_state.lock().await;
                let players: Vec<Player> = state.values().cloned().collect();
                let _ = tx.send(ServerMessage::GameState { players });
            }

            // Notify all clients about new player
            let _ = tx.send(ServerMessage::PlayerJoined {
                player_id: player_id.clone(),
                player_name,
                x: 0.0,
                y: 0.0,
                z: 0.0,
            });

            info!("Player {} joined with ID: {}", player.name, player_id);
            Some(player_id)
        }

        ClientMessage::UpdatePosition { x, y, z } => {
            if let Some(player_id) = &current_player_id {
                {
                    let mut state = game_state.lock().await;
                    if let Some(player) = state.get_mut(player_id) {
                        player.x = x;
                        player.y = y;
                        player.z = z;
                    }
                }

                // Broadcast position update to all clients
                let _ = tx.send(ServerMessage::PlayerMoved {
                    player_id: player_id.clone(),
                    x,
                    y,
                    z,
                });
            }
            current_player_id
        }

        ClientMessage::Leave => {
            if let Some(player_id) = &current_player_id {
                {
                    let mut state = game_state.lock().await;
                    state.remove(player_id);
                }

                let _ = tx.send(ServerMessage::PlayerLeft {
                    player_id: player_id.clone(),
                });
            }
            None
        }
    }
}
