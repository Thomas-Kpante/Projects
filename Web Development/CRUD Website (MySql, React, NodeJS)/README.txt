
Computer Components Ordering System
This project is a computer website where users can select the desired parts, and place an order. 
The system utilizes a MySQL database to store information about the available components and their details. The backend is built using Node.js, and the frontend is developed with React.

Project Structure

backend/: Contains the Node.js backend code.
frontend/: Consists of the React frontend code.

Prerequisites
Before running the project, make sure you have the following installed:

Node.js
npm (Node Package Manager)
Setting Up the Database
The MySQL database is not included in this project to avoid sharing sensitive information. To set up the database, follow these steps:

Install MySQL on your machine if you haven't already.

Create a new MySQL database for the project.

Update the database connection information in backend/index.js


Running the Project
Follow these steps to run the project:

Open a terminal and navigate to the backend/ directory.

Install the Node.js dependencies:

npm start

Open another terminal and navigate to the frontend/ directory.

Install the React frontend dependencies:


npm install

Run the React development server:

npm start

Access the application in your web browser at http://localhost:3000.

Usage

Select the desired components and add them to the shopping cart.

Navigate to the shopping cart, review your selections, and place the order.

Note
Ensure that your MySQL database is running and accessible before starting the backend server. If you encounter any issues, double-check your database connection details in backend/index.js.

