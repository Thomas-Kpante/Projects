<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Check if the user is logged in and is an admin
if (!isset($_SESSION['user_id']) || $_SESSION['user_role'] !== 'admin') {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}

// Fetch categories from the database
$stmt = $pdo->query("SELECT * FROM categories");
$categories = $stmt->fetchAll(PDO::FETCH_ASSOC);

$message = '';

// Handle the product submission
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Sanitize and validate inputs
    $name = filter_input(INPUT_POST, 'name', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $description = filter_input(INPUT_POST, 'description', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $price = filter_input(INPUT_POST, 'price', FILTER_VALIDATE_FLOAT);
    $imageUrl = filter_input(INPUT_POST, 'imageUrl', FILTER_SANITIZE_URL);
    $categoryId = filter_input(INPUT_POST, 'category', FILTER_VALIDATE_INT);

    if ($name && $description && $price !== false && $imageUrl && $categoryId) {
        $stmt = $pdo->prepare("INSERT INTO products (Name, Description, Price, ImageUrl, CategoryID) VALUES (?, ?, ?, ?, ?)");
        if ($stmt->execute([$name, $description, $price, $imageUrl, $categoryId])) {
            $message = 'Product added successfully!';
        } else {
            $message = 'An error occurred.';
        }
    } else {
        $message = 'Invalid input.';
    }
}

?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Ajouter Nouveau Produit</title>
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
        <h2>Nouveau produit</h2>
        
      
        <?php if ($message): ?>
            <div class="alert alert-info">
                <?php echo $message; ?>
            </div>
        <?php endif; ?>

        <form action="process_add_product.php" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="name">Nom</label>
                <input type="text" class="form-control" id="name" name="name" required>
            </div>
            <div class="form-group">
                <label for="description">Description</label>
                <textarea class="form-control" id="description" name="description" rows="3" required></textarea>
            </div>
            <div class="form-group">
                <label for="price">Prix</label>
                <input type="number" step="0.01" class="form-control" id="price" name="price" required>
            </div>
        
            <div class="form-group">
                <label for="imageUrl">Image URL</label>
                <input type="text" class="form-control" id="imageUrl" name="imageUrl" required>
            </div>
            <div class="form-group">
                <label for="category">Category</label>
                <select class="form-control" id="category" name="category" required>
                    <?php foreach ($categories as $category): ?>
                        <option value="<?php echo htmlspecialchars($category['CategoryID']); ?>">
                            <?php echo htmlspecialchars($category['CategoryName']); ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>


            <button type="submit" class="btn btn-primary">Ajouter Produits</button>
            <a href="/funko_pop_shop/admin/index.php" class="btn btn-secondary">Retour</a>
        </form>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
</body>
</html>
