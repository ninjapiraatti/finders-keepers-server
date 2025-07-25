#[cfg(test)]
mod tests {
    use crate::{ClientMessage, Player, ServerMessage};
    use serde_json;

    #[test]
    fn test_player_serialization() {
        let player = Player {
            id: "test-id".to_string(),
            name: "Test Player".to_string(),
            x: 1.0,
            y: 2.0,
            z: 3.0,
        };

        let json = serde_json::to_string(&player).unwrap();
        let deserialized: Player = serde_json::from_str(&json).unwrap();

        assert_eq!(player.id, deserialized.id);
        assert_eq!(player.name, deserialized.name);
        assert_eq!(player.x, deserialized.x);
        assert_eq!(player.y, deserialized.y);
        assert_eq!(player.z, deserialized.z);
    }

    #[test]
    fn test_client_message_serialization() {
        let join_msg = ClientMessage::Join {
            player_name: "TestPlayer".to_string(),
        };

        let json = serde_json::to_string(&join_msg).unwrap();
        let deserialized: ClientMessage = serde_json::from_str(&json).unwrap();

        match deserialized {
            ClientMessage::Join { player_name } => {
                assert_eq!(player_name, "TestPlayer");
            }
            _ => panic!("Wrong message type"),
        }
    }

    #[test]
    fn test_server_message_serialization() {
        let player_joined_msg = ServerMessage::PlayerJoined {
            player_id: "test-id".to_string(),
            player_name: "Test Player".to_string(),
            x: 0.0,
            y: 0.0,
            z: 0.0,
        };

        let json = serde_json::to_string(&player_joined_msg).unwrap();
        let deserialized: ServerMessage = serde_json::from_str(&json).unwrap();

        match deserialized {
            ServerMessage::PlayerJoined {
                player_id,
                player_name,
                x,
                y,
                z,
            } => {
                assert_eq!(player_id, "test-id");
                assert_eq!(player_name, "Test Player");
                assert_eq!(x, 0.0);
                assert_eq!(y, 0.0);
                assert_eq!(z, 0.0);
            }
            _ => panic!("Wrong message type"),
        }
    }

    #[test]
    fn test_position_update_message() {
        let update_msg = ClientMessage::UpdatePosition {
            x: 10.5,
            y: 20.3,
            z: 30.7,
        };

        let json = serde_json::to_string(&update_msg).unwrap();
        let deserialized: ClientMessage = serde_json::from_str(&json).unwrap();

        match deserialized {
            ClientMessage::UpdatePosition { x, y, z } => {
                assert_eq!(x, 10.5);
                assert_eq!(y, 20.3);
                assert_eq!(z, 30.7);
            }
            _ => panic!("Wrong message type"),
        }
    }

    #[test]
    fn test_leave_message() {
        let leave_msg = ClientMessage::Leave;
        let json = serde_json::to_string(&leave_msg).unwrap();
        let deserialized: ClientMessage = serde_json::from_str(&json).unwrap();

        match deserialized {
            ClientMessage::Leave => {
                // Test passed
            }
            _ => panic!("Wrong message type"),
        }
    }

    #[test]
    fn test_error_message() {
        let error_msg = ServerMessage::Error {
            message: "Test error".to_string(),
        };

        let json = serde_json::to_string(&error_msg).unwrap();
        let deserialized: ServerMessage = serde_json::from_str(&json).unwrap();

        match deserialized {
            ServerMessage::Error { message } => {
                assert_eq!(message, "Test error");
            }
            _ => panic!("Wrong message type"),
        }
    }

    #[test]
    fn test_game_state_message() {
        let players = vec![
            Player {
                id: "player1".to_string(),
                name: "Player One".to_string(),
                x: 1.0,
                y: 2.0,
                z: 3.0,
            },
            Player {
                id: "player2".to_string(),
                name: "Player Two".to_string(),
                x: 4.0,
                y: 5.0,
                z: 6.0,
            },
        ];

        let game_state_msg = ServerMessage::GameState {
            players: players.clone(),
        };
        let json = serde_json::to_string(&game_state_msg).unwrap();
        let deserialized: ServerMessage = serde_json::from_str(&json).unwrap();

        match deserialized {
            ServerMessage::GameState {
                players: deserialized_players,
            } => {
                assert_eq!(deserialized_players.len(), 2);
                assert_eq!(deserialized_players[0].id, "player1");
                assert_eq!(deserialized_players[1].id, "player2");
            }
            _ => panic!("Wrong message type"),
        }
    }
}
