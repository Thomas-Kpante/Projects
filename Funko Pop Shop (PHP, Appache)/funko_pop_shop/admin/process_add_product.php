<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Check if the user is logged in and is an admin
if (!isset($_SESSION['user_id']) || $_SESSION['user_role'] != 'admin') {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Extract and sanitize input data
    $name = filter_input(INPUT_POST, 'name', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $description = $_POST['description'];
    $price = filter_input(INPUT_POST, 'price', FILTER_VALIDATE_FLOAT);
    $imageUrl = filter_input(INPUT_POST, 'imageUrl', FILTER_SANITIZE_URL);
    $categoryId = filter_input(INPUT_POST, 'category', FILTER_VALIDATE_INT);

    // Basic validation
    if (!$name || !$description || !$price || !$imageUrl || !$categoryId) {
        // One or more fields are empty or invalid
        $_SESSION['flash_messages'] = ['type' => 'danger', 'message' => 'Please fill all the fields correctly.'];
        header('Location: /funko_pop_shop/admin/add_product.php');
        exit();
    }

    // Attempt to insert the new product into the database
    $sql = "INSERT INTO products (Name, Description, Price, ImageURL, CategoryID) VALUES (?, ?, ?, ?, ?)";
    $stmt = $pdo->prepare($sql);
    $success = $stmt->execute([$name, $description, $price, $imageUrl, $categoryId]);

    if ($success) {
        $_SESSION['flash_messages'] = ['type' => 'success', 'message' => 'Product added successfully!'];
    } else {
        $_SESSION['flash_messages'] = ['type' => 'danger', 'message' => 'Failed to add the product. Please try again.'];
    }

    // Redirect back to the add product page or to the product list
    header('Location: /funko_pop_shop/admin/add_product.php');
    exit();
}

// Redirect to the form if this script is accessed without submitting the form
header('Location: /funko_pop_shop/admin/add_product.php');
exit();
