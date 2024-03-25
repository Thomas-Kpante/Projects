<?php
session_start();

if (!empty($_GET['redirect']) && empty($_SESSION['redirect_to'])) {
    $_SESSION['redirect_to'] = filter_var($_GET['redirect'], FILTER_SANITIZE_URL);
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/3.1.2/rollups/aes.js"></script>
    <script>
        function cript() {
            var password = document.getElementById('password').value;
            var fullName = document.getElementById('fullName').value;
            
            var CryptoJSAesJson = {
                stringify: function (cipherParams) {
                    var j = {ct: cipherParams.ciphertext.toString(CryptoJS.enc.Base64)};
                    if (cipherParams.iv) j.iv = cipherParams.iv.toString();
                    if (cipherParams.salt) j.s = cipherParams.salt.toString();
                    return JSON.stringify(j);
                },
                parse: function (jsonStr) {
                    var j = JSON.parse(jsonStr);
                    var cipherParams = CryptoJS.lib.CipherParams.create({ciphertext: CryptoJS.enc.Base64.parse(j.ct)});
                    if (j.iv) cipherParams.iv = CryptoJS.enc.Hex.parse(j.iv);
                    if (j.s) cipherParams.salt = CryptoJS.enc.Hex.parse(j.s);
                    return cipherParams;
                }
            };

            var encrypted = CryptoJS.AES.encrypt(JSON.stringify(password), "CeciEstUneCleSecrete", {format: CryptoJSAesJson}).toString();
            document.getElementById('password').value = encrypted;

            return true;
        }
    </script>
</head>
<body>
<?php include '../includes/navbar.php'; ?>
    <div class="container">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">Connexion</h5>
                    </div>
                    <div class="card-body">
                        <?php if (isset($_GET['error']) && $_GET['error'] == 'invalid'): ?>
                            <div class="alert alert-danger" role="alert">
                                Identifiants invalides. Veuillez réessayer.
                            </div>
                        <?php endif; ?>
                        <form action="../AuthentificationServer/authentificationBD.php" method="post" id="loginForm" onsubmit="return cript();">
                            <div class="form-group">
                                <label for="fullName">Nom complet</label>
                                <input type="text" id="fullName" name="FullName" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <label for="password">Mot de passe</label>
                                <input type="password" id="password" name="Password" class="form-control" required>
                            </div>
                            <input type="hidden" name="redirect" value="/funko_pop_shop/products/list.php">
                            <button type="submit" class="btn btn-primary">Connexion</button>
                        </form>
                    </div>
                    <div class="card-footer text-center">
                        <p class="mb-0">Vous n'avez pas de compte ? <a href="create_account.php">Créer un compte</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
