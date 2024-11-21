import React, { useState, useEffect, useRef } from "react";
import socketIOClient from "socket.io-client";
import '../CSS/Lobby.css'; 
import { useLocation, useNavigate } from "react-router-dom";

const ENDPOINT = "http://127.0.0.1:4001";  

function Lobby() {
    const [players, setPlayers] = useState([]);
    const location = useLocation();
    const navigate = useNavigate();
    
    // Extract playerName from location.state (passed from Home page)
    const playerName = location.state?.playerName;

    const socketRef = useRef(null);

    useEffect(() => {
        // Initialize socket when component mounts
        socketRef.current = socketIOClient(ENDPOINT);

        // Emit join event when component mounts
        socketRef.current.emit('joinLobby', { name: playerName });

        // Listen for updated player list from the server
        socketRef.current.on('updateLobby', (players) => {
            setPlayers(players);
        });

        // Listen for the 'navigateToGame' event to navigate to the game page
        socketRef.current.on('navigateToGame', () => {
            console.log('Received navigateToGame event');  // Log when event is received
            
            // Pass the playerName to the Game page when navigating
            navigate('/game', { state: { playerName: playerName } });
        });

        // Cleanup function to handle disconnection when component unmounts
        return () => {
            socketRef.current.emit('removePlayer', playerName);
            socketRef.current.disconnect();
        };
    }, [playerName, navigate]);

    const handleHomeClick = () => {
        // Emit and disconnect using the existing socketRef
        socketRef.current.emit('removePlayer', playerName);
        socketRef.current.disconnect();
        navigate('/');  // Redirect to the home page
    };

    const handleStartClick = () => {
        // Emit to start the game
        socketRef.current.emit('startGame');
    };

    return (
        <div className="lobby-container">
            {/* Home Button */}
            <button className="home-button" onClick={handleHomeClick}>Acceuil</button>

            <h1>Attente de joueurs...</h1>
            <div id="player-list" className="player-list">
                {players.map((player, index) => (
                    <div key={index} className="player">
                        {player.name}
                    </div>
                ))}
            </div>
            <button className="start-button" onClick={handleStartClick}>Commencer</button>
        </div>
    );
}

export default Lobby;
