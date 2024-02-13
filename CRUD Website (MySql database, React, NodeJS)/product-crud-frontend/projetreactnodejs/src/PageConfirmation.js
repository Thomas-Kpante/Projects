import React, { Component } from 'react';
import './App.css';
import AppNavbar from './AppNavbar';
import { Link } from 'react-router-dom';
import { Button, Container } from 'reactstrap';
import './PageConfirmation.css';

class PageConfirmation extends Component {
    render() {
        return (
            <div className="PageConfirmation-page">
                <AppNavbar/>
                <Container fluid>
                <div className='container'>
                    <h1 className='h1Titre'> Commande Envoyer, Merci!</h1>  
                  
                </div>
                </Container>
            </div>
        );
    }
}

export default PageConfirmation;
