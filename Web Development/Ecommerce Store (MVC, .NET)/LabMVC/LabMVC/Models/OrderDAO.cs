using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;

namespace LabMVC.Models
{
    public class OrderDAO
    {
        private string connectionString = "Data Source=(local)\\SQLEXPRESS;Initial Catalog=Ecommerce;Integrated Security=True;";
        private DbProviderFactory factory;

        public OrderDAO()
        {
            factory = DbProviderFactories.GetFactory("System.Data.SqlClient");
        }

        public List<OrderVO> GetAllOrders()
        {
            var orders = new List<OrderVO>();
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    command.CommandText = "SELECT OrderID, ClientID, OrderDate, ShippingAddress, TotalAmount FROM Orders";

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var order = new OrderVO
                            {
                                OrderID = Convert.ToInt32(reader["OrderID"]),
                                ClientID = Convert.ToInt32(reader["ClientID"]),
                                OrderDate = Convert.ToDateTime(reader["OrderDate"]),
                                ShippingAddress = reader["ShippingAddress"].ToString(),
                                TotalAmount = Convert.ToDecimal(reader["TotalAmount"])
                            };
                            orders.Add(order);
                        }
                    }
                }
            }
            return orders;
        }

        public int AddOrder(OrderVO order)
        {
            int orderId = 0;
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    command.CommandText = @"
                    INSERT INTO Orders (ClientID, OrderDate, ShippingAddress, TotalAmount) 
                    OUTPUT INSERTED.OrderID
                    VALUES (@ClientID, @OrderDate, @ShippingAddress, @TotalAmount)";

                    command.Parameters.Add(new SqlParameter("@ClientID", order.ClientID));
                    command.Parameters.Add(new SqlParameter("@OrderDate", order.OrderDate));
                    command.Parameters.Add(new SqlParameter("@ShippingAddress", order.ShippingAddress));
                    command.Parameters.Add(new SqlParameter("@TotalAmount", order.TotalAmount));

                    orderId = (int)command.ExecuteScalar();
                }
            }
            return orderId;
        }

        public OrderVO GetLatestOrderWithClientDetails()
        {
            OrderVO latestOrder = null;
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    // Select the most recent order with client details
                    command.CommandText = @"
                        SELECT TOP 1 o.OrderID, o.ClientID, o.OrderDate, o.ShippingAddress, o.TotalAmount, 
                               c.FullName, c.PhoneNumber, c.Email
                        FROM Orders o
                        JOIN Client c ON o.ClientID = c.ClientID
                        ORDER BY o.OrderDate DESC";

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            latestOrder = new OrderVO
                            {
                                OrderID = Convert.ToInt32(reader["OrderID"]),
                                ClientID = Convert.ToInt32(reader["ClientID"]),
                                OrderDate = Convert.ToDateTime(reader["OrderDate"]),
                                ShippingAddress = reader["ShippingAddress"].ToString(),
                                TotalAmount = Convert.ToDecimal(reader["TotalAmount"]),
                                FullName = reader["FullName"].ToString(),
                                PhoneNumber = reader["PhoneNumber"].ToString(),
                                Email = reader["Email"].ToString()
                            };
                        }
                    }
                }
            }
            return latestOrder;
        }

        public List<OrderItemVO> GetOrderItemsByOrderId(int orderId)
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
                SELECT ProductID, Price, Quantity
                FROM OrderItems
                WHERE OrderID = @OrderID";

                    command.Parameters.Add(new SqlParameter("@OrderID", orderId));

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var orderItem = new OrderItemVO
                            {
                                ProductID = Convert.ToInt32(reader["ProductID"]),
                                Price = Convert.ToDecimal(reader["Price"]),
                                Quantity = Convert.ToInt32(reader["Quantity"])
                            };
                            orderItems.Add(orderItem);
                        }
                    }
                }
            }
            return orderItems;
        }

    }
}
