<?php
session_start();
// Ensure the user is logged in
if (!isset($_SESSION['user_id'])) {
    header('Location: /funko_pop_shop/Authentification/login.php?redirect=order');
    exit();
}

include 'includes/db_connect.php'; 



$cartItems = isset($_SESSION['cart']) ? $_SESSION['cart'] : [];

// Fetch product details from the database
$cartDetails = [];
foreach ($cartItems as $productId => $quantity) {
    $stmt = $pdo->prepare("SELECT ProductID, Name, ImageURL, Price FROM products WHERE ProductID = ?");
    $stmt->execute([$productId]);
    $productDetails = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($productDetails) {
        $cartDetails[] = [
            'ProductID' => $productDetails['ProductID'],
            'Name' => $productDetails['Name'],
            'ImageURL' => $productDetails['ImageURL'],
            'Price' => $productDetails['Price'],
            'Quantity' => $quantity,
            'Subtotal' => $productDetails['Price'] * $quantity,
        ];
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Passer Commande</title>
    <!-- Include Bootstrap CSS from CDN -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<?php include 'includes/navbar.php'; ?>
    <div class="container mt-5">
        <h2 class="mb-4">Adresse de livraison</h2>
        <form action="submit_order.php" method="post">
            <div class="form-group">
                <label for="shipping_address">Votre adresse</label>
                <textarea class="form-control" id="shipping_address" name="shipping_address" rows="3" required></textarea>
            </div>

            <h3>Articles dans votre commande</h3>
            <?php foreach ($cartDetails as $item): ?>
                <div class="media mb-3">
                    <img src="<?php echo htmlspecialchars($item['ImageURL']); ?>" class="mr-3" alt="<?php echo htmlspecialchars($item['Name']); ?>" style="width: 64px; height: 64px;">
                    <div class="media-body">
                        <h5 class="mt-0"><?php echo htmlspecialchars($item['Name']); ?></h5>
                        Quantité: <?php echo htmlspecialchars($item['Quantity']); ?> <br>
                        Prix unitaire: $<?php echo htmlspecialchars(number_format($item['Price'], 2)); ?> <br>
                        Sous-total: $<?php echo htmlspecialchars(number_format($item['Subtotal'], 2)); ?>
                    </div>
                </div>
            <?php endforeach; ?>
            
            <button type="submit" class="btn btn-primary">Placer Commande</button>
        </form>
    </div>

    <!-- Optional: Include jQuery and Bootstrap JS for interactive components -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
