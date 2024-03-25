<?php
session_start();
// Check if the user is logged in and if an order ID is set
if (!isset($_SESSION['user_id']) || !isset($_SESSION['recent_order_id'])) {
    // Redirect to home page or login page if not properly accessed
    header('Location: /funko_pop_shop/index.php');
    exit();
}

include 'includes/db_connect.php';

// Retrieve the order details, including the Order ID stored in session
$orderId = $_SESSION['recent_order_id'];

$stmt = $pdo->prepare("SELECT * FROM `orders` WHERE OrderID = ?");
$stmt->execute([$orderId]);
$orderDetails = $stmt->fetch(PDO::FETCH_ASSOC);

// Optionally, fetch order items if needed
$stmtItems = $pdo->prepare("SELECT oi.Quantity, oi.Price, p.Name 
                            FROM orderitems oi
                            JOIN products p ON oi.ProductID = p.ProductID
                            WHERE oi.OrderID = ?");
                            $stmtItems->execute([$orderId]);
$orderItems = $stmtItems->fetchAll(PDO::FETCH_ASSOC);

// Assuming we're done with the order ID in the session after displaying it
unset($_SESSION['recent_order_id']);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Confirmation de Commande</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/custom.css"> <!-- Adjust the path as needed -->
</head>

<body>
<?php include 'includes/navbar.php'; ?>
<div class="container mt-5">
    <div class="card border-primary">
        <div class="card-header bg-primary text-white">
            <h1>Merci pour votre commande!</h1>
        </div>
        <div class="card-body">
            <h5 class="card-title text-primary">Résumé de la commande</h5>
                <p class="card-text">
                    <strong>Numéro de commande:</strong> <?php echo htmlspecialchars($orderDetails['OrderID']); ?><br>
                    <strong>Date de commande:</strong> <?php echo htmlspecialchars($orderDetails['OrderDate']); ?><br>
                    <strong>Adresse de livraison:</strong> <?php echo htmlspecialchars($orderDetails['ShippingAddress']); ?><br>
                    <strong>Total:</strong> $<?php echo htmlspecialchars(number_format($orderDetails['TotalAmount'], 2)); ?>
                </p>
                <h5 class="mt-4">Articles dans votre commande</h5>
                <ul class="list-group">
                    <?php foreach ($orderItems as $item): ?>
                        <?php $totalPricePerItem = $item['Price'] * $item['Quantity']; ?>
                        <li class="list-group-item">
                            <?php echo htmlspecialchars($item['Quantity']) . "x " . htmlspecialchars($item['Name']); ?>
                            - $<?php echo htmlspecialchars(number_format($totalPricePerItem, 2)); ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
                <a href="/funko_pop_shop/products/list.php" class="btn btn-primary mt-4">Continuer de magasiner</a>
            </div>
        </div>
        <p class="text-center mt-4">Si vous avez des questions, n'hésitez pas à nous contacter.</p>
    </div>
</body>

</html>
