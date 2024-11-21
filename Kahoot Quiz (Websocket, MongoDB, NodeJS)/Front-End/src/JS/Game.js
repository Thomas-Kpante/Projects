import React, { useState, useEffect, useRef } from "react";
import socketIOClient from "socket.io-client";
import { useNavigate, useLocation } from "react-router-dom";
import '../CSS/Game.css';  // Assuming you have CSS for the game

const ENDPOINT = "http://127.0.0.1:4001";

function Game() {
    const [question, setQuestion] = useState("");
    const [options, setOptions] = useState([]);
    const [time, setTime] = useState(0);  // Keep time in decimal seconds
    const [questionId, setQuestionId] = useState(null);  // Track the current question ID
    const [submittedAnswer, setSubmittedAnswer] = useState(null);  // Track the submitted answer
    const [correctAnswer, setCorrectAnswer] = useState(null);  // Track the correct answer
    const [pointsAwarded, setPointsAwarded] = useState(null);  // Track the points awarded for the current player
    const [timeTaken, setTimeTaken] = useState(null);  // Track the time taken for the current player
    const socketRef = useRef(null);
    const navigate = useNavigate();  // For navigating to the leaderboard page
    const location = useLocation();  // Get the location object to access the passed playerName
    
    // Extract the player name from location.state (assuming it's passed from the lobby)
    const playerName = location.state?.playerName || "Unknown Player";  // Default to "Unknown Player" if not found

    useEffect(() => {
        socketRef.current = socketIOClient(ENDPOINT);
    
        // Listen for the new question from the server
        socketRef.current.on('newQuestion', (data) => {
            setQuestion(data.question);
            setOptions(data.options);
            setQuestionId(data.questionId);  // Store the question ID for answering
            setSubmittedAnswer(null);  // Reset submitted answer
            setCorrectAnswer(null);  // Reset correct answer
            setPointsAwarded(null);  // Reset points awarded
            setTimeTaken(null);  // Reset time taken
            setTime(0);  // Reset timer
    
            // Clear any previous listener to avoid duplicate handling
            socketRef.current.off('showCorrectAnswer'); // Remove any previous listener
            // Register a new listener for the correct answer
            socketRef.current.on('showCorrectAnswer', (data) => {
                setCorrectAnswer(data.correctAnswer);  // Set the correct answer
                setPointsAwarded(data.pointsAwarded);
                console.log(data.correctAnswer);
            });
        });
    
        // Start timer when the question is received, updating every 100ms (0.1 seconds)
        const timerInterval = setInterval(() => {
            setTime(prevTime => +(prevTime + 0.1).toFixed(1));  // Increment by 0.1 seconds, keep one decimal place
        }, 100);
    
        // Cleanup when the component unmounts
        return () => {
            clearInterval(timerInterval);
            socketRef.current.disconnect();
        };
    }, [navigate]);

    const handleAnswerClick = (answer) => {
        const timeAtSubmission = time;  // Capture time at the moment of submission
        setSubmittedAnswer(answer);
        setTimeTaken(timeAtSubmission);  // Save the time at submission
        setTime(null);  // Stop the timer
        console.log("NAME STORED BEING SENT")
        console.log(playerName)

        // Emit the answer submission to the server
        socketRef.current.emit('submitAnswer', {
            questionId: questionId,
            answer: answer,
            timeTaken: timeAtSubmission,
            name: playerName  // Send player's name along with the answer
        });

        // Wait for 2 seconds before navigating to the leaderboard
        setTimeout(() => {
            navigate('/leaderboard', { state: { playerName: playerName } });
        }, 5000);
    };

    const handleHomeClick = () => {
        // Emit and disconnect using the existing socketRef
        socketRef.current.emit('removePlayer', playerName);
        socketRef.current.disconnect();
        navigate('/');  // Redirect to the home page
    };

    return (
        <div className="game-container">
             <button className="home-button" onClick={handleHomeClick}>Acceuil</button>
            <h2>{question}</h2>
            <div className="options">
                {options.map((option, index) => (
                    <button
                    key={index}
                    onClick={() => handleAnswerClick(option)}
                    style={{
                        backgroundColor: option === correctAnswer ? "green" : option === submittedAnswer && option !== correctAnswer ? "red" : "",
                        color: option === correctAnswer || (option === submittedAnswer && option !== correctAnswer) ? "white" : ""
                    }}
                    disabled={!!submittedAnswer}  // Disable buttons after submission
                >
                    {option}
                </button>
                ))}
            </div>
            {submittedAnswer && (
                 <div className="result">
                 <p>Vous avez soumis: {submittedAnswer}</p>
                 <p>Temps prit: {timeTaken ? timeTaken.toFixed(1) : 0} secondes</p> {/* Show time taken with 1 decimal */}
                 {pointsAwarded !== null && (
                     <p>Points attribués: {pointsAwarded}</p>  
                 )}
             </div>
            )}
        </div>
    );
}

export default Game;
