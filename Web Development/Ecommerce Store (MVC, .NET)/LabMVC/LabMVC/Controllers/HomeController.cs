using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web.Mvc;
using LabMVC.Models;
using YourNamespace;

namespace LabMVC.Controllers
{
    public class HomeController : Controller
    {
        // Home page action
        public ActionResult Index()
        {
            return View();
        }

        // Action for displaying products
        public ActionResult Products()
        {
            // Assuming you have a ProductDAO to retrieve products from the database
            ProductDAO productDAO = new ProductDAO();
            var products = productDAO.GetAllProducts();
            return View(products);
        }

        // Action for displaying a specific product
        public ActionResult ProductDetails(int id)
        {
            // Assuming you have a method in ProductDAO to retrieve a product by its ID
            ProductDAO productDAO = new ProductDAO();
            var Product = productDAO.GetProductById(id);
            return View(Product);
        }

        // Action for adding a product to the cart
        public ActionResult AddToCart(int productId, string currentView)
        {
            // Retrieve product details using the product ID
            ProductDAO productDAO = new ProductDAO();
            var product = productDAO.GetProductById(productId);

            if (product != null)
            {
                // Retrieve cart from session state
                var cart = Session["Cart"] as Cart;
                if (cart == null)
                {
                    // If cart doesn't exist in session, create a new one
                    cart = new Cart();
                }

                // Check if the product is already in the cart
                var existingItem = cart.Items.FirstOrDefault(item => item.ProductId == productId);
                if (existingItem != null)
                {
                    // If the product is already in the cart, increase the quantity
                    existingItem.Quantity++;
                }
                else
                {
                    // If the product is not in the cart, add a new item
                    cart.AddItem(productId, product.Name, product.Price, 1);
                }

                // Store updated cart back in session state
                Session["Cart"] = cart;

                // Redirect to the product page or any other page as needed
                return RedirectToAction(currentView, "Home");
            }
            else
            {
                // Product not found, handle error or display a message
                return RedirectToAction("Acceuil", "Home");
            }
        }



        // Action method to display the contents of the cart
        public ActionResult ViewCart()
        {
            // Retrieve cart from session state
            var cart = Session["Cart"] as Cart;
            if (cart == null)
            {
                // If cart doesn't exist in session, create a new one
                cart = new Cart();
            }

            // Pass cart to the view for display
            return View(cart);
        }

        // Action for removing a product from the cart
        public ActionResult RemoveFromCart(int productId)
        {

            var cart = Session["Cart"] as Cart;
            if (cart == null)
            {

                cart = new Cart();
            }

            // Remove item from cart
            cart.RemoveItem(productId);

            // Store updated cart back in session state
            Session["Cart"] = cart;

            // Redirect to the cart page or any other page as needed
            return RedirectToAction("ViewCart");
        }

        // Action for the checkout process
        public ActionResult Checkout()
        {
            // Add logic to handle the checkout process
            return View();
        }

        // Action for displaying the confirmation page after checkout


        // Action for displaying the about page
        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";
            return View();
        }

        // Action for displaying the contact page
        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";
            return View();
        }
        public ActionResult Acceuil(string category)
        {
            ProductDAO productDAO = new ProductDAO();
            List<ProductVO> products;

            // If a category is selected, use it to filter the products
            if (!string.IsNullOrEmpty(category))
            {
                products = productDAO.GetProductsByCategory(category);
            }
            else
            {
                products = productDAO.GetAllProducts();
            }

            // Get all categories for the dropdown filter
            var categories = productDAO.GetAllCategories();

            ViewBag.Products = products;
            ViewBag.Categories = categories;

            return View();
        }


        public ActionResult Order()
        {
            // Retrieve cart from session state
            var cart = Session["Cart"] as Cart;
            if (cart == null)
            {
                // If cart is empty or not found, redirect to the cart view or any other appropriate action
                return RedirectToAction("ViewCart");
            }



            // Pass cart to the order view for review
            return View(cart);
        }

        // Action for submitting the order
        [HttpPost]


        public ActionResult PlaceOrder(string fullName, string phoneNumber, string email, string shippingAddress)
        {
            try
            {
                // Get or create the client based on the provided information
                int clientId = GetOrCreateClient(fullName, phoneNumber, email);

                // Retrieve cart from session state
                var cart = Session["Cart"] as Cart;
                if (cart == null || !cart.Items.Any())
                {
                    // If the cart is empty or not found, redirect to the cart view or any other appropriate action
                    return RedirectToAction("ViewCart");
                }

                // Instantiate DAOs
                OrderDAO orderDao = new OrderDAO();
                OrderItemDAO orderItemDao = new OrderItemDAO();

                // Create a new order object
                OrderVO newOrder = new OrderVO
                {
                    ClientID = clientId,
                    OrderDate = DateTime.Now,
                    ShippingAddress = shippingAddress,
                    TotalAmount = cart.CalculateTotal()
                };

                // Add the order to the database and retrieve the newly generated order ID
                int orderId = orderDao.AddOrder(newOrder);

                // Add order items to the database
                foreach (var item in cart.Items)
                {
                    OrderItemVO orderItem = new OrderItemVO
                    {
                        OrderID = orderId,
                        ProductID = item.ProductId,
                        Price = item.Price,
                        Quantity = item.Quantity
                    };

                    orderItemDao.AddOrderItem(orderItem);
                }

                // Clear the cart after processing the order
                Session["Cart"] = null;

                return RedirectToAction("OrderSuccess");
            }
            catch (Exception ex)
            {
                // Handle exceptions...
                return View("Error", new { message = ex.Message });
            }
        }

        private int GetOrCreateClient(string fullName, string phoneNumber, string email)
        {
            // Instantiate client DAO
            ClientDAO clientDAO = new ClientDAO();

            // Check if the client exists in the database based on the provided information
            int clientId = clientDAO.GetClientIdByFullName(fullName);

            // If the client doesn't exist, create a new client record
            if (clientId == 0)
            {
                ClientVO newClient = new ClientVO
                {
                    FullName = fullName,
                    PhoneNumber = phoneNumber,
                    Email = email
                };

                // Save the new client to the database and retrieve the newly generated client ID
                clientId = clientDAO.SaveClient(newClient);
            }

            return clientId;
        }

        public ActionResult OrderSuccess()
        {
            // Retrieve the latest order with client details from the database
            OrderDAO orderDAO = new OrderDAO();
            OrderVO latestOrder = orderDAO.GetLatestOrderWithClientDetails();

            if (latestOrder != null)
            {
                // Retrieve order items associated with the latest order
                List<OrderItemVO> orderItems = orderDAO.GetOrderItemsByOrderId(latestOrder.OrderID);

                // Assign order items to the latest order
                latestOrder.OrderItems = orderItems;

                // Pass the latest order to the confirmation view
                return View(latestOrder);
            }
            else
            {
                // Handle the case where the order is not found
                return RedirectToAction("Index"); // Redirect to the homepage or any other appropriate action
            }
        }




        [HttpPost]
        
        public ActionResult UpdateCartQuantity(int productId, int newQuantity)
        {
            // Update the quantity in the cart
            var cart = Session["Cart"] as Cart;
            if (cart != null)
            {
                cart.UpdateQuantity(productId, newQuantity);
                Session["Cart"] = cart;

                // Calculate the updated total for the specific product
                decimal productTotal = cart.GetProductTotal(productId);

                // Calculate the overall cart total
                decimal cartTotal = cart.CalculateTotal();

                // Return the updated product total and the overall cart total as JSON
                return Json(new { productTotal = productTotal, cartTotal = cartTotal });
            }

            // If the cart is not found or updated, return an error status
            return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
        }



        [HttpGet]
        public ActionResult GetCartTotal()
        {
            var cart = Session["Cart"] as Cart;
            if (cart != null)
            {
                // Calculate the total from the cart items
                decimal total = cart.CalculateTotal();
                // Return the total as JSON
                return Json(new { total = total }, JsonRequestBehavior.AllowGet);
            }
            // If the cart is not found, return an error status
            return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
        }







    }
}
