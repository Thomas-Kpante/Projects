<?php
// Include your database connection file
include '../includes/db_connect.php';
session_start();

if (!isset($_SESSION['cart'])) {
    $_SESSION['cart'] = array();
}

// Initialize $products as an empty array
$products = [];

// Check if a category or search term has been specified
$category = isset($_GET['category']) ? $_GET['category'] : null;
$search = isset($_GET['search']) ? $_GET['search'] : null;

if ($category) {
    $stmt = $pdo->prepare("SELECT * FROM Products WHERE CategoryID = (SELECT CategoryID FROM Categories WHERE CategoryName = ?)");
    $stmt->execute([$category]);
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
} elseif ($search) {

    $stmt = $pdo->prepare("SELECT * FROM Products WHERE Name LIKE ? OR Description LIKE ?");
    $searchTerm = '%' . $search . '%';
    $stmt->execute([$searchTerm, $searchTerm]);
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
} else {
    $stmt = $pdo->query("SELECT * FROM Products");
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
}
?>



<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Liste de Produits - Funko Pop Shop</title>
    <link rel="stylesheet" href="../css/navbar.css">
    <link rel="stylesheet" href="../css/style.css"> <!-- Correct the path if necessary -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <!-- Add additional styles for list page if needed -->
</head>
<body>

<?php include '../includes/navbar.php'; ?>

<div class="container mt-4">
    <h2 class="mb-4">Nos Produits</h2>
    <div class="row">
        <?php foreach ($products as $product): ?>
            <div class="col-md-4 mb-3">
                <div class="card">
                    <img class="card-img-top" src="<?php echo htmlspecialchars($product['ImageURL']); ?>" alt="<?php echo htmlspecialchars($product['Name']); ?>">
                    <div class="card-body">
                        <h5 class="card-title"><?php echo htmlspecialchars($product['Name']); ?></h5>
                        <p class="card-text"><?php echo htmlspecialchars($product['Description']); ?></p>
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="price"><?php echo number_format($product['Price'], 2, ',', ' '); ?> $</span>
                            <button onclick="addToCart(<?php echo $product['ProductID']; ?>)" class="btn btn-primary">Ajouter au Panier</button>
                        </div>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<!-- Bootstrap JS and its dependencies -->

<!-- chatgpt assisted with the script to assist the creation and usage of AJAX and others. -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
<script src="../js/ajax-cart.js"></script>

<script>
function addToCart(productId) {
    $.ajax({
        url: '../add_to_cart.php', // Correct the path according to your project structure
        type: 'POST',
        data: { product_id: productId },
        success: function(response) {
            // Assuming response is the new cart count
            updateCartCount(response);
        },
        error: function(xhr, status, error) {
            // Handle any errors here
            console.error("An error occurred: " + status + " " + error);
        }
    });
}

function updateCartCount(newCount) {
    // Update the cart count in the navbar
    $('#cart-count').text(newCount);
}
</script>

</body>
</html>