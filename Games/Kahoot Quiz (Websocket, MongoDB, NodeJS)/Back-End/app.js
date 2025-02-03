const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const mongoose = require('mongoose');

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/test', {})
    .then(() => {
        console.log('MongoDB connected');
    })
    .catch(err => {
        console.error('MongoDB connection error:', err);
    });

// Define the schema for questions
const Question = mongoose.model('Question', new mongoose.Schema({
    question: String,
    options: [String],
    correctAnswer: String,
    category: String
}), 'testing');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    },
    pingInterval: 25000,  
    pingTimeout: 60000   
});

app.use(cors());

let players = []; // To track connected players by name
let leaderboard = []; // To track each player's name and score
let hasSubmitted = {}; // Track if each player has submitted an answer
let gameStartTime = null;  // Store the start time globally
let currentQuestion = null; // Track the current question
let askedQuestions = [];  // Track questions that have been asked
let questionCount = 0;  // Track the number of questions asked
let playersOnLeaderboard = [];  // Track players who reached the leaderboard

const MAX_QUESTIONS = 5;  // Set the limit to 5 questions

// Utility function to get the leaderboard
const getLeaderboard = () => {
    console.log('Leaderboard array:', leaderboard);  // Log the leaderboard array for debugging
    return leaderboard;
};

// Function to find or create a player in the leaderboard by name
const findOrCreatePlayer = (playerName) => {
    let player = leaderboard.find(p => p.name === playerName);

    if (!player) {
        player = { name: playerName, score: 0 };  // Ensure the score is initialized as 0
        leaderboard.push(player); // Add the new player to the leaderboard
        console.log(`Player added to leaderboard: ${playerName}`); // Debugging log
    } else {
        console.log(`Player found in leaderboard: ${player.name}`); // Debugging log
    }

    return player;
};

// When a new client connects
io.on('connection', (socket) => {
    console.log('New client connected:', socket.id);

    socket.on('joinLobby', (player) => {
        console.log('joinLobby event triggered');
        console.log('Received player data:', player);
    
        // Check if the player already exists in the array, whether connected or disconnected
        let existingPlayer = players.find(p => p.name === player.name);
    
        if (existingPlayer && existingPlayer.disconnected) {
            // If the player exists and was disconnected, update their socket ID and reconnect them
            existingPlayer.id = socket.id;
            existingPlayer.disconnected = false;
            console.log(`Player reconnected: ${player.name} with new ID: ${socket.id}`);
        } else if (existingPlayer) {
            // If the player is still connected, prevent duplicate names
            socket.emit('nameExists', { error: "Nom déjà séléctionné." });
            console.log(`Player with name ${player.name} already exists. Emitting nameExists error.`);
            socket.disconnect();
            return;
        } else {
            // Otherwise, add the player as a new entry if they don't already exist
            players.push({ name: player.name, id: socket.id, disconnected: false });
            console.log(`Player added to players array: ${player.name} with ID: ${socket.id}`);
        }
    
        findOrCreatePlayer(player.name); // Ensure player is in the leaderboard
        io.emit('updateLobby', players);
        io.emit('updateLeaderboard', getLeaderboard());
    });
    

    // Start the game and send a question
socket.on('startGame', async () => {
    console.log('Start Game event received');
    playersOnLeaderboard = [];  // Clear the playersOnLeaderboard array
    if (players.length >= 2 && questionCount < MAX_QUESTIONS) {
        try {
            io.emit('navigateToGame');  // Navigate all players to the game

            gameStartTime = Date.now();

            // Fetch a random question from MongoDB, excluding previously asked questions
            const question = await Question.aggregate([
                { $match: { _id: { $nin: askedQuestions } } },  // Exclude already asked questions
                { $sample: { size: 1 } }  // Get one random question
            ]);

            console.log('Question fetched:', question);

            if (question.length === 0) {
                socket.emit('error', { message: 'No more questions available' });
                return;
            }

            // Add the question to the askedQuestions list
            askedQuestions.push(question[0]._id);
            questionCount++;  // Increment the question count

            // Emit the question to all players
            setTimeout(() => {
                io.emit('newQuestion', {
                    question: question[0].question,
                    options: question[0].options,
                    questionId: question[0]._id
                });
            }, 2000);

            // Reset player submission status
            players.forEach(player => {
                hasSubmitted[player.name] = false;
            });

        } catch (error) {
            console.error('Error fetching question:', error);
            socket.emit('error', { message: 'An error occurred while fetching the question' });
        }
    } else if (questionCount >= MAX_QUESTIONS) {
        // If the maximum number of questions has been reached, show the final leaderboard
        io.emit('finalLeaderboard', getLeaderboard());
    }
});

    socket.on('submitAnswer', async (data) => {
        console.log('Answer received from player:', data);
    
        // Try to find the player by their socket ID
        let player = players.find(p => p.id === socket.id);
    
        // If not found by socket ID, attempt to find the player by name
        if (!player) {
            console.log(`Player with socket ID ${socket.id} not found, attempting to find by name: ${data.name}`);
            player = players.find(p => p.name === data.name);
    
            // If the player is not found by name, create a new player
            if (!player) {
                console.log(`Player with name ${data.name} not found. Adding player dynamically.`);
    
                // Add player to players array
                player = { name: data.name, id: socket.id, disconnected: false };
                players.push(player);
    
                // Add player to the leaderboard
                findOrCreatePlayer(data.name);
            } else {
                // If found by name, update their socket ID
                console.log(`Player ${player.name} found by name, updating socket ID to: ${socket.id}`);
                player.id = socket.id;  // Update the player's socket ID to the new one
            }
        }
    
        const playerName = player.name;
    
        // Check if the player has already submitted
        if (hasSubmitted[playerName]) {
            console.log(`Player ${playerName} has already submitted an answer.`);
            return;
        }
    
        console.log(`Processing answer for player ${playerName}.`);
    
        // Calculate the time taken and points awarded
        const timeTaken = (Date.now() - gameStartTime) / 1000;
        const maxPoints = 100;
        const penalty = Math.min(timeTaken, 50);
        let pointsAwarded = Math.max(0, maxPoints - penalty);
        pointsAwarded = Math.round(pointsAwarded);
    
        try {
            const correctQuestion = await Question.findById(data.questionId);
    
            if (!correctQuestion) {
                console.log(`No question found with ID: ${data.questionId}`);
                return;
            }
    
            const playerInLeaderboard = findOrCreatePlayer(playerName);
    
            if (data.answer === correctQuestion.correctAnswer) {
                playerInLeaderboard.score += pointsAwarded;
                console.log(`Player ${playerName} answered correctly and earned ${pointsAwarded} points.`);
            } else {
                pointsAwarded = 0;
                console.log(`Player ${playerName} answered incorrectly.`);
            }
    
            // Mark that the player has submitted
            hasSubmitted[playerName] = true;
    
            // Send the correct answer to the client and show it on the screen
            io.to(socket.id).emit('showCorrectAnswer', {
                correctAnswer: correctQuestion.correctAnswer,
                pointsAwarded: pointsAwarded
            });

            
    
            console.log(`Correct answer sent to ${playerName}.`);
            console.log(`Correct answer sent ${correctQuestion.correctAnswer}.`);
    
            // Emit the updated leaderboard after processing the answer
            io.emit('updateLeaderboard', getLeaderboard());
    
        } catch (error) {
            console.error('Error fetching correct question or processing answer:', error);
        }
    });

    // When a player reaches the leaderboard
socket.on('playerOnLeaderboard', (playerName) => {
    console.log(`${playerName} reached the leaderboard`);

    if (!playersOnLeaderboard.includes(playerName)) {
        playersOnLeaderboard.push(playerName);  // Add player to the list
    }

    // If all players are on the leaderboard, enable the Next Question button
    if (playersOnLeaderboard.length === players.length) {
        console.log('All players are on the leaderboard. Enabling Next Question.');
        io.emit('enableNextQuestion');  // Emit event to enable the Next Question button
    }
});



    // Handle the leaderboard request event
    socket.on('requestLeaderboard', () => {
        console.log('Leaderboard request received from:', socket.id);
        io.emit('updateLeaderboard', getLeaderboard());  // Emit the current leaderboard to all clients
    });

    // Handle player disconnection
    socket.on('disconnect', () => {
        const player = players.find(p => p.id === socket.id);
        if (player) {
            player.disconnected = true;  // Mark as disconnected but don't remove from the array
            console.log(`Player marked as disconnected: ${player.name}`);
        }
        io.emit('updateLobby', players);
        io.emit('updateLeaderboard', getLeaderboard());
    });
    
      // Handle player leaving the game and going back to the lobby
      socket.on('removePlayer', (playerName) => {
        console.log(`Removing player: ${playerName}`);
    
        // Remove the player from the players array
        players = players.filter(player => player.name !== playerName);
    
        // Also remove them from the leaderboard and submission tracking
        leaderboard = leaderboard.filter(player => player.name !== playerName);
        delete hasSubmitted[playerName];
    
        console.log('Updated players array after removal:', players);
        console.log('Updated leaderboard array after removal:', leaderboard);
    
        io.emit('updateLobby', players);
        io.emit('updateLeaderboard', getLeaderboard());
    });
    
});

server.listen(4001, () => console.log(`Server running on http://localhost:4001`));
