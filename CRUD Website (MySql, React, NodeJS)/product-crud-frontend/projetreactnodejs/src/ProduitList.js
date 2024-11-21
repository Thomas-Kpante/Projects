//code contient certaine partie qui vien de https://www.baeldung.com/spring-boot-react-crud

import React, { Component } from 'react';
import { Button, ButtonGroup, Container, Table } from 'reactstrap';
import AppNavbar from './AppNavbar';
import { Link } from 'react-router-dom';
import './ProduitList.css';

class ProduitList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      produits: [],
      isLoading: true,
    };
    this.remove = this.remove.bind(this);
  }

  async componentDidMount() {
    this.setState({ isLoading: true });
  
    try {
      const response = await fetch('http://localhost:8080/produits');
      const dataString = await response.text();
      console.log('Raw data from server:', dataString);
  
      const data = JSON.parse(dataString);
      console.log('Type of data:', typeof data); // Log the type of data
  
      if (Array.isArray(data)) {
        this.setState({ produits: data, isLoading: false });
      } else {
        console.error('Error fetching produits: Unexpected data structure:', data);
        this.setState({ isLoading: false });
      }
    } catch (error) {
      console.error('Error fetching produits:', error.message, error.stack);
      this.setState({ isLoading: false });
    }
  }
  
  

  async remove(id) {
    await fetch(`http://localhost:8080/produits/${id}`, {
      method: 'DELETE',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    });

    // Update the state to remove the deleted produit
    const updatedProduits = this.state.produits.filter(produit => produit.id !== id);
    this.setState({ produits: updatedProduits });
  }

  render() {
    const { produits, isLoading } = this.state;

    if (isLoading) {
      return <p>Loading...</p>;
    }

    const produitList = produits.map(produit => (
      <tr key={produit.id}>
        <td>{produit.Nom}</td>
        <td>{produit.Description}</td>
        <td>
          <ButtonGroup>
            <Button size="sm" color="primary" tag={Link} to={`/produits/${produit.id}`} style={
              {backgroundColor: 'gray',
              marginRight: '10px',
              paddingLeft: '10px',
              borderColor: 'transparent'
              }}>Modifier</Button>
            <Button size="sm" color="danger" onClick={() => this.remove(produit.id)}>Supprimer</Button>
          </ButtonGroup>
        </td>
      </tr>
    ));

    return (
      <div className="produit-page">
        <AppNavbar />
        <Container fluid>
          <h3 className='H3'>Création de l'ordinateur</h3>
          <Table>
            <thead>
              <tr>
                <th width="30%">Composant</th>
                <th width="30%">Model</th>
                <th width="40%">Actions</th>
              </tr>
            </thead>
            <tbody>
              {produitList}
            </tbody>
          </Table>
          <div className="float-right">
            <Button color="warning" tag={Link} to="/produits/new"  style={
              {
              marginRight: '10px',
              paddingLeft: '10px',
              borderColor: 'transparent'
              }}>Ajouter un composant</Button>

            <Button color="success" tag={Link} to="/commande">Confirmer Commande</Button>
          </div>
         
        </Container>
      </div>
    );
  }
}

export default ProduitList;
