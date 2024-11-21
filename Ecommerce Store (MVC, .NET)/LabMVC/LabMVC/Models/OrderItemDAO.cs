using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;

namespace LabMVC.Models
{
    public class OrderItemDAO
    {
        private string connectionString = "Data Source=(local)\\SQLEXPRESS;Initial Catalog=Ecommerce;Integrated Security=True;";
        private DbProviderFactory factory;

        public OrderItemDAO()
        {
            // Initialize the factory
            factory = DbProviderFactories.GetFactory("System.Data.SqlClient");
        }

        public List<OrderItemVO> GetOrderItemsByOrderID(int orderID)
        {
            var orderItems = new List<OrderItemVO>();
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    command.CommandText = @"
                        SELECT oi.OrderItemID, oi.OrderID, oi.ProductID, p.Name, oi.Price, oi.Quantity
                        FROM OrderItems oi
                        INNER JOIN Products p ON oi.ProductID = p.ProductID
                        WHERE oi.OrderID = @OrderID";
                    command.Parameters.Add(new SqlParameter("@OrderID", orderID));

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var orderItem = new OrderItemVO
                            {
                                OrderItemID = Convert.ToInt32(reader["OrderItemID"]),
                                OrderID = Convert.ToInt32(reader["OrderID"]),
                                ProductID = Convert.ToInt32(reader["ProductID"]),
                                ProductName = reader["Name"].ToString(),
                                Price = Convert.ToDecimal(reader["Price"]),
                                Quantity = Convert.ToInt32(reader["Quantity"])
                                
                            };
                            orderItems.Add(orderItem);
                            Console.WriteLine(orderItem.Quantity.ToString());
                        }
                    }
                }
            }
            return orderItems;
        }

        public void AddOrderItem(OrderItemVO orderItem)
        {
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    command.CommandText = @"
                        INSERT INTO OrderItems (OrderID, ProductID, Price, Quantity) 
                        VALUES (@OrderID, @ProductID, @Price, @Quantity)";

                    // Add parameters to prevent SQL injection WITH CHATGPT HELP
                    command.Parameters.Add(new SqlParameter("@OrderID", orderItem.OrderID));
                    command.Parameters.Add(new SqlParameter("@ProductID", orderItem.ProductID));
                    command.Parameters.Add(new SqlParameter("@Price", orderItem.Price));
                    command.Parameters.Add(new SqlParameter("@Quantity", orderItem.Quantity));

                    command.ExecuteNonQuery();
                }
            }
        }

      
    }
}
