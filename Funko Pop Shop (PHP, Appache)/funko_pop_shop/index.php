<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Funko Pop Shop</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/style.css"> <!-- Ensure this contains the path to your custom CSS -->
    <style>
        body, html {
            height: 100%;
            margin: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            background-color: #f8f9fa; /* Or any color that matches your branding */
        }
        .instruction-text {
            margin-bottom: 20px; /* Add some space between the text and the logo */
            font-size: 24px; /* Larger font size for the instruction */
            font-weight: bold;
            text-align: center;
            color: #333; /* Color for the text */
        }
        .logo-button {
            border: none;
            background: transparent;
            cursor: pointer;
        }
        .logo-button:focus {
            outline: none;
        }
    </style>
</head>
<body>

    <div class="instruction-text">
        Cliquez sur notre logo pour voir notre inventaire Funko Pop!
    </div>

    <button class="logo-button" onclick="window.location.href='products/list.php';">
        <img src="https://i.imgur.com/l2YCEgQ.png" alt="Boutique Funko Pop" width="500" height="200">
    </button>

    <!-- Bootstrap JS and its dependencies (optional, only if you need Bootstrap's JS components) -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>

</body>
</html>
