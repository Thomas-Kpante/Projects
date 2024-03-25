<?php
$cart_count = isset($_SESSION['cart']) ? array_sum($_SESSION['cart']) : 0;
?>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <a class="navbar-brand" href="/funko_pop_shop/index.php">
    <img src="https://i.imgur.com/0uKmwRO.png" alt="Funko Pop Shop" height="60">
  </a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="collapse navbar-collapse justify-content-between" id="navbarNav">
    <ul class="navbar-nav">
      <li class="nav-item active">
          <a class="nav-link" href="/funko_pop_shop/products/list.php">Inventaire</a>
      </li>
      <li class="nav-item">
          <a class="nav-link" href="/funko_pop_shop/products/list.php?category=heros">Héros</a>
      </li>
      <li class="nav-item">
          <a class="nav-link" href="/funko_pop_shop/products/list.php?category=villains">Villains</a>
      </li>
      <!-- Additional navigation items -->
    </ul>
    <form class="form-inline my-2 my-lg-0" action="list.php" method="GET">
      <input class="form-control mr-sm-2" type="search" placeholder="Search" aria-label="Search" name="search">
      <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Rechercher</button>
    </form>
    <ul class="navbar-nav">
      <li class="nav-item">
          <a class="nav-link" href="/funko_pop_shop/cart.php">
          Panier <span id="cart-count" class="badge badge-pill badge-secondary"><?php echo $cart_count; ?></span>
          </a>
      </li>
      <?php if (isset($_SESSION['user_role']) && $_SESSION['user_role'] == 'admin'): ?>
      <li class="nav-item">
        <a class="nav-link" href="/funko_pop_shop/admin/index.php">Dashboard Admin</a>
      </li>
      <?php endif; ?>
      <?php if(isset($_SESSION['user_id'])): ?>
        <!-- Display Log out if user is logged in -->
        <li class="nav-item">
          <a class="nav-link" href="/funko_pop_shop/Authentification/logout.php">Déconnexion <span class="fas fa-sign-out-alt"></span></a>
        </li>
      <?php else: ?>
        <!-- Display Log in if user is not logged in -->
        <li class="nav-item">
          <a class="nav-link" href="/funko_pop_shop/Authentification/login.php">Se Connecter <span class="fas fa-user"></span></a>
        </li>
      <?php endif; ?>
    </ul>
  </div>
</nav>
