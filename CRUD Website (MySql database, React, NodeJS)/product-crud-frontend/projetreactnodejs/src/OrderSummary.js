//code contient certaine partie qui vien de https://www.baeldung.com/spring-boot-react-crud

import React, { Component } from 'react';
import { Button, ButtonGroup, Container, Table } from 'reactstrap';
import AppNavbar from './AppNavbar';
import { Link } from 'react-router-dom';
import './OrderSummary.css';



class OrderSummary extends Component {

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
    
        // Fetch produits from your API
        try {
          const response = await fetch('http://localhost:8080/produits');
          const data = await response.json();
          this.setState({ produits: data, isLoading: false });
        } catch (error) {
          console.error('Error fetching produits:', error.message, error.stack);
          this.setState({ isLoading: false });
        }
      }
    
      async remove(id) {
        await fetch(`/produits/${id}`, {
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
    
        const orderList = produits.map(produit => (
          <tr key={produit.id}>
            <td>{produit.Nom}</td>
            <td>{produit.Description}</td>
          </tr>
        ));
                
  
        return (
            
            <div>
                <AppNavbar/>
            <div className="Order-Page">
                <Container fluid className='TableContainer'>
          <h3 className='H3'>Commande</h3>
          <Table>
            <thead>
              <tr>
                <th width="30%">Composant</th>
                <th width="30%">Model</th>
              </tr>
            </thead>
            <tbody>
              {orderList}
            </tbody>
          </Table>
          <div className="float-right">
            <Button color="warning" tag={Link} to="/produits"  style={
              {
              marginRight: '10px',
              paddingLeft: '10px',
              borderColor: 'transparent'
              }}>Retour</Button>

            <Button color="success" tag={Link} to="/confirmation">Envoyer Commande</Button>
          </div>
         
        </Container>
            </div>
            </div>
        );
    
}
}
export default OrderSummary;
