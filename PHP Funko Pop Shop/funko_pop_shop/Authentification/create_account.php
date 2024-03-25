<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Créer un compte</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
</head>
<body>
<?php include '../includes/navbar.php'; ?>
    <div class="container">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">Créer un compte</h5>
                    </div>
                    <div class="card-body">
                        <form action="process_create_account.php" method="post">
                            <div class="form-group">
                                <label for="fullName">Nom complet</label>
                                <input type="text" id="fullName" name="FullName" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <label for="phoneNumber">Numéro de téléphone</label>
                                <input type="text" id="phoneNumber" name="PhoneNumber" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <label for="email">Adresse email</label>
                                <input type="email" id="email" name="Email" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <label for="password">Mot de passe</label>
                                <input type="password" id="password" name="Password" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <input type="hidden" id="role" name="Role" value="user">
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">Créer le compte</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
