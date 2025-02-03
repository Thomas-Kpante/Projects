import React, { useState, useEffect, useRef } from "react";
import socketIOClient from "socket.io-client";
import '../CSS/Leaderboard.css';  // Add your leaderboard CSS here
import { useNavigate, useLocation } from 'react-router-dom';  // Assuming you're using React Router

const ENDPOINT = "http://127.0.0.1:4001";

function Leaderboard() {
    const [leaderboard, setLeaderboard] = useState([]);
    const [isNextQuestionEnabled, setIsNextQuestionEnabled] = useState(false);  // Track if the Next Question button is enabled
    const [isFinal, setIsFinal] = useState(false);  // State to track if it's the final leaderboard
    const socketRef = useRef(null);
    const navigate = useNavigate();
    const location = useLocation();  // Get the location object to access the passed playerName

    const playerName = location.state?.playerName || "Unknown Player";  // Default to "Unknown Player" if not found

    useEffect(() => {
        socketRef.current = socketIOClient(ENDPOINT);

        socketRef.current.emit('playerOnLeaderboard', playerName);

        socketRef.current.emit('requestLeaderboard');

        // Listen for the updated leaderboard data
        socketRef.current.on('updateLeaderboard', (data) => {
            console.log('Updated leaderboard data received:', data);  // Debugging log
            if (data && Array.isArray(data)) {
                setLeaderboard(data.sort((a, b) => b.score - a.score));  // Sort by score descending
            } else {
                console.error("Invalid leaderboard data received", data);
            }
        });

        socketRef.current.on('enableNextQuestion', () => {
            setIsNextQuestionEnabled(true);
        });


        // Listen for the navigateToGame event to start the next question
        socketRef.current.on('navigateToGame', () => {
            console.log('Received navigateToGame event');  // Log when event is received
            // Pass the playerName to the Game page when navigating
            navigate('/game', { state: { playerName: playerName } });
        });

        // Listen for the finalLeaderboard event from the server
        socketRef.current.on('finalLeaderboard', (data) => {
            console.log('Final leaderboard received:', data);
            if (data && Array.isArray(data)) {
                setLeaderboard(data.sort((a, b) => b.score - a.score));  // Update leaderboard
                setIsFinal(true);  // Set the final state to true
            } else {
                console.error("Invalid final leaderboard data received", data);
            }
        });

        // Cleanup interval and socket connection when the component unmounts
        return () => {
            socketRef.current.disconnect();  // Disconnect socket
        };
    }, [navigate]);

    const handleNextRound = () => {
        // Emit an event to start the next round
        socketRef.current.emit('startGame');
    };

    const handleHomeClick = () => {
        // Emit and disconnect using the existing socketRef
        socketRef.current.emit('removePlayer', playerName);
        socketRef.current.disconnect();
        navigate('/');  // Redirect to the home page
    };

    return (
        <div className="leaderboard-container">
            <button className="home-button" onClick={handleHomeClick}>Acceuil</button>
            <h1>{isFinal ? 'Classement Final' : 'Classement'}</h1>
            {leaderboard.length > 0 ? (
                <ul className="leaderboard-list">
                    {leaderboard.map((player, index) => (
                        <li key={index}>
                            {player.name}: {Math.round(player.score)} points
                        </li>
                    ))}
                </ul>
            ) : (
                <p>Attente de données</p>
            )}

            {/* Show Next Round button only if the game is not over */}
            {!isFinal && (
               <button className="next-round-button" onClick={handleNextRound} disabled={!isNextQuestionEnabled}>
               Prochaine Question
           </button>
            )}

            {/* display a message when the game is over */}
            {isFinal && (
                <div className="game-over-message">
                    <p>Le quiz est terminé! Merci de vous avoir prêté au jeu!</p>
                </div>
            )}
        </div>
    );
}

export default Leaderboard;
