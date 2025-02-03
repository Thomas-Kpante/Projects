
# Hockey Quiz Web App

A real-time multiplayer hockey quiz application built using **Node.js**, **Socket.IO**, and **React.js**. This application allows players to join a lobby, participate in a quiz with a maximum of 5 questions, and view a real-time leaderboard. Each player's time to answer and points awarded are calculated, and the game ensures that no player can proceed to the next round until all players have finished.

## Table of Contents
1. [Features](#features)
2. [Technologies](#technologies)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Project Structure](#project-structure)
6. [Game Flow](#game-flow)
7. [Contributing](#contributing)
8. [License](#license)

## Features
- **Real-time Multiplayer**: Allows multiple players to join the quiz in real-time.
- **Dynamic Leaderboard**: Players are ranked by points based on their speed and accuracy.
- **Time and Points Calculation**: Each question gives points based on how quickly the answer is submitted.
- **Question Tracking**: Ensures no repeated questions within the same quiz session.
- **Final Leaderboard**: After 5 questions, the final leaderboard is displayed.
- **Player Disconnection Handling**: Tracks and updates player states if they disconnect and reconnect.

## Technologies
- **Backend**:
  - Node.js
  - Express.js
  - Socket.IO
  - MongoDB
- **Frontend**:
  - React.js
  - Socket.IO Client

## Installation

### Prerequisites
- **Node.js** (v12 or later)
- **MongoDB** (Ensure MongoDB is running on localhost)

### Steps
1. Clone this repository:
   \`\`\`bash
   git clone https://github.com/your-username/hockey-quiz.git
   \`\`\`
2. Navigate to the project directory:
   \`\`\`bash
   cd hockey-quiz
   \`\`\`
3. Install backend dependencies:
   \`\`\`bash
   npm install
   \`\`\`
4. Install frontend dependencies:
   Navigate to the `client` folder and run:
   \`\`\`bash
   cd client
   npm install
   \`\`\`
5. Start MongoDB:
   Ensure MongoDB is running locally on the default port (27017). You can start MongoDB using:
   \`\`\`bash
   mongod
   \`\`\`
6. Start the server:
   Run the following command to start the backend server:
   \`\`\`bash
   npm run start
   \`\`\`
7. Start the frontend:
   In another terminal, navigate to the `client` folder and run:
   \`\`\`bash
   npm start
   \`\`\`

The app will be available at `http://localhost:3000` for the frontend and `http://localhost:4001` for the backend.

## Usage
1. Open the app in your browser at `http://localhost:3000`.
2. Enter your name and click the "Join the Quiz Lobby" button to enter the game.
3. Once 2 or more players have joined the lobby, click "Start Game" to begin the quiz.
4. Players answer questions in real-time, and the leaderboard updates dynamically.
5. After 5 questions, the final leaderboard will be shown, and the game ends.

## Project Structure
\`\`\`
.
├── client                   # React frontend
│   ├── src                  # Source code for the frontend
│   ├── public               # Public assets
│   ├── CSS                  # Stylesheets
│   └── package.json         # Frontend dependencies
├── server                   # Node.js and Express backend
│   ├── models               # MongoDB Models for questions
│   ├── routes               # API endpoints
│   ├── socket.js            # Main Socket.IO event handling logic
│   ├── app.js               # Entry point for Express server
│   └── package.json         # Backend dependencies
├── README.md                # Project documentation
└── .env                     # Environment variables (for MongoDB, etc.)
\`\`\`

## Game Flow

1. **Joining the Lobby**: Players join the game lobby by entering their names. The server ensures unique names and prevents duplicate entries.
2. **Starting the Quiz**: When at least 2 players are in the lobby, any player can start the quiz. The game begins, and a question is fetched from the MongoDB database.
3. **Answering Questions**: Players have a limited time to answer each question. Points are awarded based on the time taken to submit the correct answer.
4. **Leaderboard**: After each question, the leaderboard is updated and displayed. Players must wait until everyone finishes before moving to the next question.
5. **Final Leaderboard**: After 5 questions, the final leaderboard is shown, and no more questions can be asked.

## Contributing

1. Fork the repository.
2. Create your feature branch: \`git checkout -b feature/YourFeature\`
3. Commit your changes: \`git commit -m 'Add your feature'\`
4. Push to the branch: \`git push origin feature/YourFeature\`
5. Submit a pull request.

## License
This project is licensed under the MIT License. See the \`LICENSE\` file for details.
