//code contient certaine partie qui vien de https://www.baeldung.com/spring-boot-react-crud

import React from 'react';
import './App.css';
import Home from './Home';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom'; // Updated import
import ProduitList from './ProduitList';
import ProduitEdit from './ProduitEdit';
import OrderSummary from './OrderSummary';
import PageConfirmation from './PageConfirmation';

function App() {
  return (
    <Router>
      <Routes>
        <Route path='/' element={<Home />} />
        <Route path='/produits' element={<ProduitList />} />
        <Route path='/produits/:id' element={<ProduitEdit />} />
        <Route path='/commande' element={<OrderSummary />} />
        <Route path='/confirmation' element={<PageConfirmation />} />
      </Routes>
    </Router>
  );
}

export default App;
