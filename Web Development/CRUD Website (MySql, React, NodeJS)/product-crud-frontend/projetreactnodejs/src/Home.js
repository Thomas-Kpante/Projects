//code contient certaine partie qui vien de https://www.baeldung.com/spring-boot-react-crud

import React, { Component } from 'react';
import './App.css';
import AppNavbar from './AppNavbar';
import { Link } from 'react-router-dom';
import { Button, Container } from 'reactstrap';
import backgroundImage from './Image/Ordinateur_Background.jpg';
import './Home.css';

class Home extends Component {
    render() {
        return (
            <div className="home-page">
                <AppNavbar/>
                <Container fluid>
                <div className='container'>
                    <h1 className='h1Titre'> Bienvenue au constructeur d'ordinateur Trex Informatique </h1>  
                    <Link to="/produits" className='commencer'>
                     Commencer
                     </Link>
                </div>
                </Container>
            </div>
        );
    }
}

export default Home;
