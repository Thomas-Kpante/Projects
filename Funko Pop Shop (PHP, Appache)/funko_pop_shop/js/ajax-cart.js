//used chatgpt to help with AJAX functions

document.addEventListener('DOMContentLoaded', (event) => {
    document.querySelectorAll('.add-to-cart').forEach(button => {
        button.addEventListener('click', (e) => {
            const productId = e.target.dataset.productId;
            
            fetch('add_to_cart.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'product_id=' + productId
            })
            .then(response => response.text())
            .then(text => {
                document.getElementById('cart-count').innerText = text;
            })
            .catch(error => console.error('Error:', error));
        });
    });
});
