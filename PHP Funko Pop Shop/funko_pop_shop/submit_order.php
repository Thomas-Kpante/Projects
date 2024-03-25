<?php
session_start();
require_once 'includes/db_connect.php'; // Adjust the path as needed

if (!isset($_SESSION['user_id'])) {
    // User not logged in, redirect to login page
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}
error_log('TEST', 3, '../debug.log');
// Example data for debugging
// $_SESSION['cart'] = [1 => 2, 2 => 1]; // Assuming cart format is [ProductID => Quantity]

$clientId = $_SESSION['user_id'];

if (!isset($_POST['shipping_address'])) {
    // Handle the case where shipping_address is not provided
    $_SESSION['error_message'] = "Please provide a shipping address.";
    header('Location: /funko_pop_shop/order.php');
    exit;
}

$shippingAddress = $_POST['shipping_address'];
$totalAmount = 0;

// Logging path adjusted to root funko_pop_shop directory
$logPath = __DIR__ . 'debug.log'; // Adjust according to your directory structure

file_put_contents($logPath, "Order submission started\n", FILE_APPEND);

try {
    $pdo->beginTransaction();

    $stmt = $pdo->prepare("INSERT INTO `orders` (ClientID, ShippingAddress, TotalAmount) VALUES (?, ?, 0)");
    if (!$stmt->execute([$clientId, $shippingAddress])) {
        throw new Exception("Failed to insert order.");
    }
    $orderId = $pdo->lastInsertId();
    file_put_contents($logPath, "Order inserted with ID: $orderId\n", FILE_APPEND);

    foreach ($_SESSION['cart'] as $productId => $quantity) {
        $productStmt = $pdo->prepare("SELECT Price FROM products WHERE ProductID = ?");
        $productStmt->execute([$productId]);
        $product = $productStmt->fetch(PDO::FETCH_ASSOC);

        if (!$product) {
            throw new Exception("Product with ID $productId not found.");
        }

        $price = $product['Price'];
        $totalAmount += $price * $quantity;

        $itemStmt = $pdo->prepare("INSERT INTO orderitems (OrderID, ProductID, Quantity, Price) VALUES (?, ?, ?, ?)");
        if (!$itemStmt->execute([$orderId, $productId, $quantity, $price])) {
            throw new Exception("Failed to insert order item for product ID: $productId");
        }
    }

    $updateStmt = $pdo->prepare("UPDATE `orders` SET TotalAmount = ? WHERE OrderID = ?");
    if (!$updateStmt->execute([$totalAmount, $orderId])) {
        throw new Exception("Failed to update total amount for order ID: $orderId");
    }

    $pdo->commit();

    // Optionally clear the cart here
    // unset($_SESSION['cart']);

    file_put_contents($logPath, "Order completed successfully. Total amount: $totalAmount\n", FILE_APPEND);
    $_SESSION['recent_order_id'] = $orderId; // For use in the order confirmation page
    unset($_SESSION['cart']);
    header('Location: /funko_pop_shop/order_confirmation.php'); // Adjust the path as needed
    exit;
} catch (Exception $e) {
    $pdo->rollBack();
    file_put_contents("debug.log", "Error processing order: " . $e->getMessage() . "\n", FILE_APPEND);
    // Handle error, e.g., redirect to a page with an error message
    $_SESSION['error_message'] = "There was a problem processing your order. Please try again.";
    header('Location: /funko_pop_shop/cart.php'); // Adjust the path as needed
    exit;
}
?>
