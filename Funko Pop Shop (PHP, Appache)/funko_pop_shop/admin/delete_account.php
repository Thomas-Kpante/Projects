<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Security check: only for admins
if (!isset($_SESSION['user_role']) || $_SESSION['user_role'] != 'admin') {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}

// Check if ID parameter is set
if (!isset($_GET['id']) || empty($_GET['id'])) {
    header('Location: manage_accounts.php');
    exit;
}

// Fetch user account data based on the ID parameter
$id = $_GET['id'];
$stmt = $pdo->prepare("SELECT * FROM client WHERE ClientID = ?");
$stmt->execute([$id]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

// If user not found, redirect to manage_accounts.php
if (!$user) {
    header('Location: manage_accounts.php');
    exit;
}

// If form submitted, delete user account and associated orders
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Start a transaction
        $pdo->beginTransaction();

        // Delete order items associated with the orders belonging to the user
        $deleteOrderItemsStmt = $pdo->prepare("DELETE oi FROM orderitems oi JOIN orders o ON oi.OrderID = o.OrderID WHERE o.ClientID = ?");
        $deleteOrderItemsStmt->execute([$id]);

        // Delete orders associated with the user account
        $deleteOrdersStmt = $pdo->prepare("DELETE FROM orders WHERE ClientID = ?");
        $deleteOrdersStmt->execute([$id]);

        // Delete user from the database
        $deleteUserStmt = $pdo->prepare("DELETE FROM client WHERE ClientID = ?");
        $deleteUserStmt->execute([$id]);

        // Commit the transaction
        $pdo->commit();

        // If delete successful, redirect to manage_accounts.php
        $_SESSION['flash_messages'] = ['type' => 'success', 'message' => 'User account and associated orders deleted successfully!'];
        header('Location: manage_accounts.php');
        exit;
    } catch (PDOException $e) {
        $errorMessage = 'Error deleting user account and associated orders: ' . $e->getMessage();
        $debugInfo = 'User ID: ' . $id . ', Error Code: ' . $e->getCode();
        error_log($errorMessage . '. ' . $debugInfo, 3, '../debug.log');
        // Rollback the transaction on error
        $pdo->rollBack();
        $_SESSION['flash_messages'] = ['type' => 'danger', 'message' => 'Failed to delete user account and associated orders. Please try again.'];
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Supprimer le compte utilisateur</title>
    <!-- Bootstrap CSS CDN -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <?php include '../includes/navbar.php'; ?>
    <div class="container">
        <h2 class="my-4">Supprimer le compte utilisateur</h2>
        <p>Êtes-vous sûr de vouloir supprimer le compte utilisateur suivant?</p>
        <p><strong>Nom complet:</strong> <?= htmlspecialchars($user['FullName']) ?></p>
        <p><strong>Email:</strong> <?= htmlspecialchars($user['Email']) ?></p>
        <p><strong>Rôle:</strong> <?= htmlspecialchars($user['Role']) ?></p>
        <form method="post">
            <button type="submit" class="btn btn-danger">Supprimer</button>
        </form>
    </div>
    <!-- Bootstrap JS and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
