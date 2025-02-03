<?php
session_start();

// Update item quantity
if (isset($_GET['product_id']) && isset($_GET['quantity'])) {
    $productId = $_GET['product_id'];
    $quantity = $_GET['quantity'];

    if ($quantity > 0) {
        $_SESSION['cart'][$productId] = $quantity;
    } else {
        unset($_SESSION['cart'][$productId]); // Remove item if quantity is 0 or less
    }
}

// Remove item
if (isset($_GET['remove'])) {
    $productId = $_GET['remove'];
    unset($_SESSION['cart'][$productId]);
}

header('Location: cart.php'); // Redirect back to the cart page
exit();
?>
