<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

function isAdmin() {
    global $pdo;
    if (!isset($_SESSION['user_id'])) return false;
    
    $stmt = $pdo->prepare("SELECT Role FROM client WHERE ClientID = ?");
    $stmt->execute([$_SESSION['user_id']]);
    $user = $stmt->fetch();
    
    return $user && $user['Role'] === 'admin';
}

if (!isAdmin()) {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .admin-link {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<?php include '../includes/navbar.php'; ?>
    <div class="container mt-5">
        <h1>Admin Dashboard</h1>
        <div class="list-group">
            <a href="add_product.php" class="list-group-item list-group-item-action admin-link">Add New Product</a>
            <a href="manage_accounts.php" class="list-group-item list-group-item-action admin-link">Manage Accounts</a>
            <a href="view_orders.php" class="list-group-item list-group-item-action admin-link">View Orders</a>
            <!-- Add more links as needed -->
        </div>
    </div>

    <!-- Bootstrap Bundle with Popper -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
