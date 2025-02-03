# Inventory Management Application

This project is an **Inventory Management Application** built using **Django** for the backend and **React** for the frontend. The application allows users to manage product inventory, including adding, updating, and deleting products, as well as generating a shopping list for products below a specified stock threshold.

## Features

- **CRUD Operations**: Add, update, delete, and view inventory items.
- **Shopping List Generation**: Automatically flag items that fall below the minimum stock threshold and generate a downloadable PDF shopping list.
- **REST API**: Django REST Framework enables smooth communication between the backend and frontend.
- **Responsive Frontend**: Built with React for a dynamic user experience.

## Tech Stack

- **Backend**: Django, Django REST Framework
- **Frontend**: React, Axios, jsPDF (for PDF generation)
- **Database**: SQLite (default Django database, can be configured to other databases if needed)

## Project Structure

- **backend/**: Django backend for API services and data handling.
  - `models.py`: Defines the `Inventory` model for products.
  - `views.py`: Implements RESTful CRUD operations.
  - `serializers.py`: Converts data to and from JSON for API requests.
  - `urls.py`: Maps API endpoints for inventory operations.
- **frontend/**: React frontend for interacting with the backend and managing the UI.
  - `App.js`: Main component handling navigation and CRUD actions.
  - `ProductDetail.js`: Component for adding and editing product details.
  - `Axios` is used for making HTTP requests to the backend.

## Installation and Setup

### Prerequisites

- **Node.js** and **npm** for running the React frontend.
- **Python 3** and **pip** for setting up the Django backend.

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/inventory-management.git
   cd inventory-management

