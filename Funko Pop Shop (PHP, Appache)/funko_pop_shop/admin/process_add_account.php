<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Extract and sanitize input data
    $fullName = filter_input(INPUT_POST, 'fullName', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL);
    $password = filter_input(INPUT_POST, 'password'); // Password already encrypted in the client side
    $phoneNumber = filter_input(INPUT_POST, 'phoneNumber', FILTER_SANITIZE_NUMBER_INT);
    $role = filter_input(INPUT_POST, 'role');

    // Basic validation
    if (empty($fullName) || empty($email) || empty($password) || empty($role)) {
        $_SESSION['flash_message'] = ['type' => 'danger', 'message' => 'Veuillez remplir tous les champs.'];
        header('Location: add_account.php');
        exit();
    }

    // Check if the email already exists in the database
    $checkEmailStmt = $pdo->prepare("SELECT COUNT(*) FROM client WHERE Email = ?");
    $checkEmailStmt->execute([$email]);
    if ($checkEmailStmt->fetchColumn() > 0) {
        $_SESSION['flash_message'] = ['type' => 'danger', 'message' => 'L\'email existe déjà.'];
        header('Location: add_account.php');
        exit();
    }

    // Insert the new user into the database
    $insertStmt = $pdo->prepare("INSERT INTO client (FullName, Email, Password, PhoneNumber, Role) VALUES (?, ?, ?, ?, ?)");
    $success = $insertStmt->execute([$fullName, $email, $password, $phoneNumber, $role]);

    if ($success) {
        $_SESSION['flash_message'] = ['type' => 'success', 'message' => 'Compte ajouté avec succès!'];
    } else {
        $_SESSION['flash_message'] = ['type' => 'danger', 'message' => 'Échec de l\'ajout du compte. Veuillez réessayer.'];
    }

    header('Location: manage_accounts.php');
    exit();
}

// If the script is accessed without submitting the form, redirect back to the form page
header('Location: add_account.php');
exit();
?>
