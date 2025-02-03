<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Security check: only for admins
if (!isset($_SESSION['user_role']) || $_SESSION['user_role'] != 'admin') {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}

// Step 1: Fetch unique orders
$ordersStmt = $pdo->query("SELECT DISTINCT o.OrderID, o.OrderDate, o.ShippingAddress, o.TotalAmount
                           FROM orders o");
$orders = $ordersStmt->fetchAll(PDO::FETCH_ASSOC);

// Prepare an array to hold order items keyed by OrderID
$orderItems = [];

// Step 2: Fetch all order items
$itemsStmt = $pdo->query("SELECT oi.OrderID, p.Name AS ProductName, p.Price AS ProductPrice, oi.Quantity
                          FROM orderitems oi
                          JOIN products p ON oi.ProductID = p.ProductID");
$items = $itemsStmt->fetchAll(PDO::FETCH_ASSOC);

// Organize items by OrderID
foreach ($items as $item) {
    $orderItems[$item['OrderID']][] = $item;
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Visualiser les commandes</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <style>
        .container {
            margin-top: 20px;
        }
        .table {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <?php include '../includes/navbar.php'; ?>
    <div class="container">
        <h2>Visualiser les commandes</h2>
        <table class="table">
            <thead>
                <tr>
                    <th>ID de commande</th>
                    <th>Date de commande</th>
                    <th>Adresse de livraison</th>
                    <th>Total</th>
                    <th>Articles</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($orders as $order): ?>
                <tr>
                    <td><?= htmlspecialchars($order['OrderID']) ?></td>
                    <td><?= htmlspecialchars($order['OrderDate']) ?></td>
                    <td><?= htmlspecialchars($order['ShippingAddress']) ?></td>
                    <td>$<?= htmlspecialchars(number_format($order['TotalAmount'], 2)) ?></td>
                    <td>
                        <?php 
                        if (isset($orderItems[$order['OrderID']])) {
                            $itemsList = [];
                            foreach ($orderItems[$order['OrderID']] as $item) {
                                $itemsList[] = htmlspecialchars($item['ProductName']) . " x " . htmlspecialchars($item['Quantity']) . " - $" . number_format($item['ProductPrice'] * $item['Quantity'], 2);
                            }
                            echo implode(', ', $itemsList);
                        }
                        ?>
                    </td>
                    <td>
                        <form action="delete_order.php" method="post">
                            <input type="hidden" name="order_id" value="<?= $order['OrderID'] ?>">
                            <button type="submit" class="btn btn-danger">Supprimer</button>
                        </form>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
        <a href="/funko_pop_shop/admin/index.php" class="btn btn-secondary">Retour</a>
    </div>
</body>
</html>
