<?php
include '../includes/db_connect.php';
include '../DecryptionServer/decrypt.php';

session_start();

$errorMessage = '';
error_log('Fonctionne', 3, '../debug.log');

if (isset($_POST['FullName']) && isset($_POST['Password'])) {
    $fullName = $_POST['FullName'];
    $encryptedPassword = $_POST['Password'];

    // Decrypt the password
    $decryptedPassword = cryptoJsAesDecrypt('CeciEstUneCleSecrete', $encryptedPassword);
    $decryptedPassword = trim($decryptedPassword, "\"");


    // Fetch the user from the database
    $stmt = $pdo->prepare("SELECT * FROM client WHERE FullName = ?");
    $stmt->execute([$fullName]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && $decryptedPassword === $user['Password']) {
        $_SESSION['user_id'] = $user['ClientID'];
        $_SESSION['user_name'] = $user['FullName'];
        $_SESSION['user_role'] = $user['Role'];
        error_log($user['ClientID'], 3, '../debug.log');

       // Default redirection if 'redirect_to' is not set or if you want to ignore it for debugging
$redirectPage = '/funko_pop_shop/products/list.php';

// Only use $_SESSION['redirect_to'] if you are sure it's being set correctly
if (!empty($_SESSION['redirect_to'])) {
    $redirectPage = $_SESSION['redirect_to'];
    unset($_SESSION['redirect_to']);
} elseif (!empty($_POST['redirect'])) {
    $redirectPage = filter_var($_POST['redirect'], FILTER_SANITIZE_URL);
} elseif (!empty($_GET['redirect'])) {
    // If redirect is specified in the URL, use it
    $redirectPage = filter_var($_GET['redirect'], FILTER_SANITIZE_URL);
} else {
    // Default redirect if no specific location is specified
    $redirectPage = '/funko_pop_shop/products/list.php';
}



header("Location: $redirectPage");
exit();

    } else {
        // Login failed
        $errorMessage = "Invalid login credentials.";

        // Append an error message to debug.log
        error_log("Login failed for FullName: $fullName with decrypted password: $decryptedPassword\n", 3, "debug.log");
        
        $_SESSION['errorMessage'] = $errorMessage;
        header('Location: ../Authentification/login.php?error=invalid');
        exit();
    }
} else {
    // If the necessary POST data isn't set, redirect to the login page with an error
    header('Location: ../Authentification/login.php?error=invalid');
    exit();
}
?>
