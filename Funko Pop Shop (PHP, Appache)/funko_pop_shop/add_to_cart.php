<?php
session_start();

//chatgpt assisted for dynamic cart addition display

if (isset($_POST['product_id'])) {
    $product_id = $_POST['product_id'];
    // Initialize cart array if it doesn't exist
    if (!isset($_SESSION['cart'])) {
        $_SESSION['cart'] = array();
    }
    // Add or update the quantity of the product in the cart
    if (!isset($_SESSION['cart'][$product_id])) {
        $_SESSION['cart'][$product_id] = 0;
    }
    $_SESSION['cart'][$product_id]++;
    
    // Output the new cart count
    echo array_sum($_SESSION['cart']);
} else {
    echo "Error: No product ID provided.";
}
?>
