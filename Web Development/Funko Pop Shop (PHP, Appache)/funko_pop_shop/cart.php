<?php
session_start();
include 'includes/db_connect.php';

// Initialize an array to hold full details of cart items
$cartItems = [];
$totalPrice = 0;

// Check if the cart is not empty
if (!empty($_SESSION['cart'])) {
    $placeholders = implode(',', array_fill(0, count($_SESSION['cart']), '?')); 
    $stmt = $pdo->prepare("SELECT * FROM Products WHERE ProductID IN ($placeholders)");
    $stmt->execute(array_keys($_SESSION['cart'])); 
    $cartItems = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Calculate total price
    foreach ($cartItems as $item) {
        $totalPrice += $item['Price'] * $_SESSION['cart'][$item['ProductID']];
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Mon Panier - Funko Pop Shop</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
</head>
<body>

<?php include 'includes/navbar.php'; ?>

<div class="container">
    <h2>Votre Panier</h2>
    <?php if (!empty($cartItems)): ?>
        <table class="table">
            <thead>
                <tr>
                    <th>Produit</th>
                    <th>Prix</th>
                    <th>Quantité</th>
                    <th>Total</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($cartItems as $item): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($item['Name']); ?></td>
                        <td><?php echo htmlspecialchars($item['Price']); ?> $</td>
                        <td>
                            <form action="update_cart.php" method="get" class="form-inline">
                                <input type="number" name="quantity" value="<?php echo $_SESSION['cart'][$item['ProductID']]; ?>" min="1" class="form-control">
                                <input type="hidden" name="product_id" value="<?php echo $item['ProductID']; ?>">
                                <button type="submit" class="btn btn-info btn-sm">Update</button>
                            </form>
                        </td>
                        <td><?php echo htmlspecialchars($item['Price'] * $_SESSION['cart'][$item['ProductID']]); ?> $</td>
                        <td>
                            <a href="update_cart.php?remove=<?php echo $item['ProductID']; ?>" class="btn btn-danger btn-sm">Retirer</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
                <tr>
                    <td colspan="3" class="text-right"><strong>Total</strong></td>
                    <td><?php echo htmlspecialchars($totalPrice); ?> $</td>
                    <td></td>
                </tr>
            </tbody>
        </table>
        <div class="text-right">
    <?php if (isset($_SESSION['user_id'])): ?>
        <!-- User is logged in, show direct link to place order -->
        <a href="order.php" class="btn btn-success">Placer Commande</a>
    <?php else: ?>
        <!-- User is not logged in, redirect to login page first -->
        <a href="/funko_pop_shop/Authentification/login.php?redirect=/funko_pop_shop/cart.php" class="btn btn-success">Placer Commande</a>

    <?php endif; ?>
</div>

    <?php else: ?>
        <p>Votre panier est vide.</p>
    <?php endif; ?>
</div>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>

</body>
</html>
