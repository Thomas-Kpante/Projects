using System;
using System.Collections.Generic;
using System.Linq;

namespace YourNamespace
{
    public class CartItem
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public decimal Total => Price * Quantity; // Calculated property for total price of this item
    }

    public class Cart
    {
        private readonly List<CartItem> _items;

        public Cart()
        {
            _items = new List<CartItem>();
        }

        // Method to add an item to the cart
        public void AddItem(int productId, string productName, decimal price, int quantity)
        {
            // Check if the item already exists in the cart
            var existingItem = _items.FirstOrDefault(item => item.ProductId == productId);

            if (existingItem != null)
            {
                // If the item already exists, update its quantity
                existingItem.Quantity += quantity;
            }
            else
            {
                // If the item does not exist, add it to the cart
                _items.Add(new CartItem
                {
                    ProductId = productId,
                    ProductName = productName,
                    Price = price,
                    Quantity = quantity
                });
            }
        }

        // Method to remove an item from the cart
        public void RemoveItem(int productId)
        {
            var itemToRemove = _items.FirstOrDefault(item => item.ProductId == productId);
            if (itemToRemove != null)
            {
                _items.Remove(itemToRemove);
            }
        }

        // Method to update the quantity of an item in the cart
        public void UpdateQuantity(int productId, int newQuantity)
        {
            var itemToUpdate = _items.FirstOrDefault(item => item.ProductId == productId);
            if (itemToUpdate != null)
            {
                itemToUpdate.Quantity = newQuantity;
            }
        }

        // Method to get the total price for a specific product in the cart
        public decimal GetProductTotal(int productId)
        {
            var item = _items.FirstOrDefault(i => i.ProductId == productId);
            if (item != null)
            {
                return item.Total;
            }
            else
            {
                return 0; // Return 0 if the product is not found in the cart
            }
        }

        // Method to calculate the total price of all items in the cart
        public decimal CalculateTotal()
        {
            return _items.Sum(item => item.Total);
        }

        // Property to retrieve the items in the cart
        public IEnumerable<CartItem> Items => _items;
    }
}