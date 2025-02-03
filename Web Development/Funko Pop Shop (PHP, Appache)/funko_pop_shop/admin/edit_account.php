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

// If form submitted, update user account
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fullName = $_POST['full_name'];
    $email = $_POST['email'];
    $role = $_POST['role'];

    // Update user data in the database
    $updateStmt = $pdo->prepare("UPDATE client SET FullName = ?, Email = ?, Role = ? WHERE ClientID = ?");
    $success = $updateStmt->execute([$fullName, $email, $role, $id]);

    // If update successful, redirect to manage_accounts.php
    if ($success) {
        $_SESSION['flash_messages'] = ['type' => 'success', 'message' => 'User account updated successfully!'];
        header('Location: manage_accounts.php');
        exit;
    } else {
        $_SESSION['flash_messages'] = ['type' => 'danger', 'message' => 'Failed to update user account. Please try again.'];
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Modifier le compte utilisateur</title>
    <!-- Bootstrap CSS CDN -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <?php include '../includes/navbar.php'; ?>
    <div class="container">
        <h2 class="my-4">Modifier le compte utilisateur</h2>
        <form method="post">
            <div class="form-group">
                <label for="full_name">Nom complet</label>
                <input type="text" class="form-control" id="full_name" name="full_name" value="<?= htmlspecialchars($user['FullName']) ?>" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" class="form-control" id="email" name="email" value="<?= htmlspecialchars($user['Email']) ?>" required>
            </div>
            <div class="form-group">
                <label for="role">Rôle</label>
                <select class="form-control" id="role" name="role">
                    <option value="admin" <?= $user['Role'] === 'admin' ? 'selected' : '' ?>>Admin</option>
                    <option value="user" <?= $user['Role'] === 'user' ? 'selected' : '' ?>>User</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Enregistrer</button>
            <a href="/funko_pop_shop/admin/manage_accounts.php" class="btn btn-secondary">Retour</a>
        </form>
        
    </div>
    <!-- Bootstrap JS and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
