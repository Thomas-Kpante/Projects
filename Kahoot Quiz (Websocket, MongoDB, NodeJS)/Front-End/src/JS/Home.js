import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import '../CSS/Home.css';  
import socketIOClient from "socket.io-client";

const ENDPOINT = "http://127.0.0.1:4001";  

function Home() {
    const [playerName, setPlayerName] = useState("");
    const [error, setError] = useState("");  // State to track errors
    const navigate = useNavigate();

    const handleJoinLobby = () => {
        if (!playerName) {
            alert("Please enter your name");
            return;
        }

        // Initialize socket connection to check name availability
        const socket = socketIOClient(ENDPOINT);

        // Emit a request to check if the name exists
        socket.emit('joinLobby', { name: playerName });

        // Listen for the "nameExists" event from the server
        socket.on('nameExists', (data) => {
            setError(data.error);  // Show the error if the name is taken
            socket.disconnect();   // Disconnect socket if the name is taken
        });

        // Listen for successful join (no nameExists error)
        socket.on('updateLobby', () => {
            setError("");  // Clear error if no issues
            socket.disconnect();   // Disconnect before navigating
            navigate('/lobby', { state: { playerName } });
        });
    };

    return (
        <div className="home-container">
            <h1>Bienvenue Au Quiz De Hockey!</h1>

            <input
                type='text'
                placeholder='Nom'
                value={playerName}
                onChange={(e) => setPlayerName(e.target.value)}
            />

            <button onClick={handleJoinLobby}>Rejoindre la salle d'attente</button>

            {/* Display error message if the name is taken */}
            {error && <p style={{ color: 'red' }}>{error}</p>}
        </div>
    );
}

export default Home;
