<?php
session_start();
require_once '../includes/db_connect.php'; // Adjust the path as needed

// Check if the form data has been submitted
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Extract and sanitize input data
    $fullName = filter_input(INPUT_POST, 'FullName', FILTER_SANITIZE_STRING);
    $phoneNumber = filter_input(INPUT_POST, 'PhoneNumber', FILTER_SANITIZE_STRING);
    $email = filter_input(INPUT_POST, 'Email', FILTER_SANITIZE_EMAIL);
    $password = filter_input(INPUT_POST, 'Password', FILTER_SANITIZE_STRING);
    $role = filter_input(INPUT_POST, 'Role', FILTER_SANITIZE_STRING);

    // Prepare and execute the SQL statement to insert the new user into the database
    $stmt = $pdo->prepare("INSERT INTO client (FullName, PhoneNumber, Email, Password, Role) VALUES (?, ?, ?, ?, ?)");
    $success = $stmt->execute([$fullName, $phoneNumber, $email, $password, $role]);

    if ($success) {
        // If insertion is successful, redirect to login page
        $_SESSION['flash_message'] = 'Votre compte a été créé avec succès. Veuillez vous connecter.';
        header('Location: /funko_pop_shop/Authentification/login.php');
        exit();
    } else {
        // If insertion fails, redirect back to the create account page with an error message
        $_SESSION['flash_message'] = 'Une erreur s\'est produite lors de la création de votre compte. Veuillez réessayer.';
        header('Location: create_account.php');
        exit();
    }
} else {
    // If the form data has not been submitted via POST, redirect to the create account page
    header('Location: create_account.php');
    exit();
}
?>
