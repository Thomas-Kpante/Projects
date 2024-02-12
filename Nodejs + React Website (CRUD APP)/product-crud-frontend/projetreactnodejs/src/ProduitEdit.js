//code contient certaine partie qui vien de https://www.baeldung.com/spring-boot-react-crud

import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { Button, Container, Form, FormGroup, Input, Label } from 'reactstrap';
import AppNavbar from './AppNavbar';
import './ProduitEdit.css';

function ProduitEdit() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [item, setItem] = useState({
    Description: '',
    Nom: '',
  });

  useEffect(() => {
    const fetchData = async () => {
      if (id !== 'new') {
        const produit = await (await fetch(`http://localhost:8080/produits/${id}`)).json();
        // Check if "data" is an array and has at least one element
        if (produit.data && produit.data.length > 0) {
          // Update state with the first element of the "data" array
          setItem(produit.data[0]);
        }
      }
    };
  
    fetchData();
  }, [id]);
  

  const handleChange = (event) => {
    const target = event.target;
    const value = target.value;
    const name = target.name;
    setItem((prevItem) => ({ ...prevItem, [name]: value }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    await fetch('http://localhost:8080/produits' + (item.id ? `/${item.id}` : ''), {
      method: item.id ? 'PUT' : 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(item),
    });

    navigate('/produits');
  };

  const title = <h2>{item.id ? 'Edit Produit' : 'Add Produit'}</h2>;

  return (
    <div>
      <AppNavbar />
      <div className="before">
        <Container className="container">
          {title}
          <Form onSubmit={handleSubmit}>
            <FormGroup>
              <Label for="name">Name</Label>
              <Input
                type="text"
                name="Nom"
                id="Nom"
                value={item.Nom || ''}
                onChange={handleChange}
                autoComplete="Nom"
              />
            </FormGroup>
            <FormGroup>
              <Label for="Description">Description</Label>
              <Input
               type="text"
               name="Description"  // Update the name here
               id="Description"
               value={item.Description || ''}
               onChange={handleChange}
               autoComplete="Description"
              />
            </FormGroup>
            <FormGroup>
              <Button color="primary" type="submit">
                Save
              </Button>{' '}
              <Button color="secondary" tag={Link} to="/produits">
                Cancel
              </Button>
            </FormGroup>
          </Form>
        </Container>
      </div>
    </div>
  );
}

export default ProduitEdit;
