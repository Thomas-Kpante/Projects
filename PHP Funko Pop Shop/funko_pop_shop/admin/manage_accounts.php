<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Security check: only for admins
if (!isset($_SESSION['user_role']) || $_SESSION['user_role'] != 'admin') {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}

// Fetch all user accounts
$usersQuery = $pdo->query("SELECT ClientID, FullName, Email, Role FROM client");
$users = $usersQuery->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Gérer les comptes</title>
    <!-- Bootstrap CSS CDN -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <!-- Custom CSS for additional styling (optional) -->
    <link rel="stylesheet" href="path/to/your/custom/styles.css">
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
        <h2 class="mb-4">Gestion des comptes</h2>
        <a href="add_account.php" class="btn btn-success mb-2">Ajouter un compte</a>
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="thead-dark">
                    <tr>
                        <th>ID du client</th>
                        <th>Nom complet</th>
                        <th>Email</th>
                        <th>Rôle</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($users as $user): ?>
                    <tr>
                        <td><?= htmlspecialchars($user['ClientID']) ?></td>
                        <td><?= htmlspecialchars($user['FullName']) ?></td>
                        <td><?= htmlspecialchars($user['Email']) ?></td>
                        <td><?= htmlspecialchars($user['Role']) ?></td>
                        <td>
                            <a href="edit_account.php?id=<?= $user['ClientID'] ?>" class="btn btn-info btn-sm">Modifier</a>
                            <a href="delete_account.php?id=<?= $user['ClientID'] ?>" class="btn btn-danger btn-sm">Supprimer</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
            <a href="/funko_pop_shop/admin/index.php" class="btn btn-secondary">Retour</a>
        </div>
    </div>
    <!-- Bootstrap JS and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
