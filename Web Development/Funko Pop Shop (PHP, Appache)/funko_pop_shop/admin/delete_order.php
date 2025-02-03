<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Security check: only for admins
if (!isset($_SESSION['user_role']) || $_SESSION['user_role'] != 'admin') {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}

// Check if the order ID is provided
if (!isset($_POST['order_id'])) {
    // Redirect back to the view_orders.php page with an error message
    $_SESSION['flash_messages'] = ['type' => 'danger', 'message' => 'Order ID is missing.'];
    header('Location: /funko_pop_shop/admin/view_orders.php');
    exit;
}

// Get the order ID from the POST data
$orderID = $_POST['order_id'];

try {
    // Delete order items first
    $deleteOrderItemsStmt = $pdo->prepare("DELETE FROM orderitems WHERE OrderID = ?");
    $deleteOrderItemsStmt->execute([$orderID]);

    // Then delete the order
    $deleteOrderStmt = $pdo->prepare("DELETE FROM orders WHERE OrderID = ?");
    $deleteOrderStmt->execute([$orderID]);

    // Redirect back to the view_orders.php page with a success message
    $_SESSION['flash_messages'] = ['type' => 'success', 'message' => 'Order deleted successfully.'];
    header('Location: /funko_pop_shop/admin/view_orders.php');
    exit;
} catch (PDOException $e) {
    // Handle any database errors
    echo "Error: " . $e->getMessage();
}
?>
