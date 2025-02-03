import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Home from "./JS/Home"; 
import Lobby from "./JS/Lobby"; 
import Game from "./JS/Game";
import Leaderboard from "./JS/Leaderboard";


function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/lobby" element={<Lobby />} />
        <Route path="/Game" element={<Game />} />
        <Route path="/leaderboard" element={<Leaderboard />} />
      </Routes>
    </Router>
  );
}

export default App;
