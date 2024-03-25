<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Security check: only for admins
if (!isset($_SESSION['user_role']) || $_SESSION['user_role'] != 'admin') {
    header('Location: /funko_pop_shop/Authentification/login.php');
    exit;
}

// If form submitted, process the data
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Extract and sanitize input data
    $fullName = filter_input(INPUT_POST, 'fullName', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL);
    $password = $_POST['password']; // Password is already encrypted client-side
    $role = filter_input(INPUT_POST, 'role', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

    // Validate input data
    if (!$fullName || !$email || !$password || !$role) {
        $_SESSION['flash_messages'] = ['type' => 'danger', 'message' => 'Please fill all the fields correctly.'];
        header('Location: add_account.php');
        exit;
    }

    // Attempt to insert the new account into the database
    $sql = "INSERT INTO client (FullName, Email, Password, Role) VALUES (?, ?, ?, ?)";
    $stmt = $pdo->prepare($sql);
    $success = $stmt->execute([$fullName, $email, $password, $role]);

    // Check if the insertion was successful
    if ($success) {
        $_SESSION['flash_messages'] = ['type' => 'success', 'message' => 'Account added successfully!'];
        header('Location: manage_accounts.php');
        exit;
    } else {
        $_SESSION['flash_messages'] = ['type' => 'danger', 'message' => 'Failed to add the account. Please try again.'];
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Ajouter un compte utilisateur</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
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
        <h2>Ajouter un compte</h2>
        <form action="process_add_account.php" method="POST">
            <div class="form-group">
                <label for="fullName">Nom complet</label>
                <input type="text" class="form-control" id="fullName" name="fullName" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" class="form-control" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="password">Mot de passe</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label for="phoneNumber">Numéro de téléphone</label>
                <input type="tel" class="form-control" id="phoneNumber" name="phoneNumber">
            </div>
            <div class="form-group">
                <label for="role">Rôle</label><br>
                <select class="form-control" id="role" name="role">
                    <option value="admin">Admin</option>
                    <option value="user">User</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Ajouter</button>
            <a href="/funko_pop_shop/admin/index.php" class="btn btn-secondary">Retour</a>
        </form>
    </div>
    <!-- Bootstrap JS and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <!-- CryptoJS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
    <script>
        function cript() {
            var password = document.getElementById('password').value;
            var fullName = document.getElementById('fullName').value;

            var encrypted = CryptoJS.AES.encrypt(JSON.stringify(password), "CeciEstUneCleSecrete", {format: CryptoJSAesJson}).toString();
            document.getElementById('password').value = encrypted;

            return true; // Proceed with form submission
        }
    </script>
</body>
</html>
