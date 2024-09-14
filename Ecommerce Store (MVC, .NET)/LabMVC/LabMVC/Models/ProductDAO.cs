using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;

namespace LabMVC.Models
{
    class ProductDAO
    {
        private string connectionString = "Data Source=(local)\\SQLEXPRESS;Initial Catalog=Ecommerce;Integrated Security=True;";

        private DbProviderFactory factory;

        public ProductDAO()
        {
            // Initialize the factory based on the provider
            factory = DbProviderFactories.GetFactory("System.Data.SqlClient");
        }

        public List<ProductVO> GetAllProducts()
        {
            var products = new List<ProductVO>();
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    command.CommandText = "SELECT ProductID, Name, Description, Price, CategoryID, ImageURL FROM Products";

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(new ProductVO
                            {
                                ProductID = Convert.ToInt32(reader["ProductID"]),
                                Name = reader["Name"].ToString(),
                                Description = reader["Description"].ToString(),
                                Price = Convert.ToDecimal(reader["Price"]),
                                CategoryID = reader["CategoryID"].ToString(),
                                ImageURL = reader["ImageURL"].ToString()

                            });
                        }
                    }
                }
            }
            return products;
        }

        //used chatgpt to help me build the sql query
        public ProductVO GetProductById(int productId)
        {
            ProductVO product = null;
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    command.CommandText = "SELECT ProductID, Name, Description, Price, CategoryID, ImageURL FROM Products WHERE ProductID = @ProductId";
                    command.Parameters.Add(new SqlParameter("@ProductId", productId));

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            product = new ProductVO
                            {
                                ProductID = Convert.ToInt32(reader["ProductID"]),
                                Name = reader["Name"].ToString(),
                                Description = reader["Description"].ToString(),
                                Price = Convert.ToDecimal(reader["Price"]),
                                CategoryID = reader["CategoryID"].ToString(),
                                ImageURL = reader["ImageURL"].ToString()

                            };
                        }
                    }
                }
            }
            return product;
        }

        public List<CategoryVO> GetAllCategories()
        {
            var categories = new List<CategoryVO>();
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    command.CommandText = "SELECT CategoryID, CategoryName FROM Categories"; // Adjust the query based on your actual table and column names

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            categories.Add(new CategoryVO
                            {
                                CategoryID = reader["CategoryID"].ToString(),
                                CategoryName = reader["CategoryName"].ToString(),
                            });
                        }
                    }
                }
            }
            return categories;
        }

        public List<ProductVO> GetProductsByCategory(string category)
        {
            var products = new List<ProductVO>();
            using (var connection = factory.CreateConnection())
            {
                connection.ConnectionString = connectionString;
                connection.Open();

                using (var command = factory.CreateCommand())
                {
                    command.Connection = connection;
                    // Join Products with Categories to filter by category name
                    command.CommandText = @"
                SELECT p.ProductID, p.Name, p.Description, p.Price, p.CategoryID, p.ImageURL 
                FROM Products AS p
                INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
                WHERE c.CategoryName = @CategoryName";
                    command.Parameters.Add(new SqlParameter("@CategoryName", category));

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(new ProductVO
                            {
                                ProductID = Convert.ToInt32(reader["ProductID"]),
                                Name = reader["Name"].ToString(),
                                Description = reader["Description"].ToString(),
                                Price = Convert.ToDecimal(reader["Price"]),
                                CategoryID = reader["CategoryID"].ToString(),
                                ImageURL = reader["ImageURL"].ToString()
                            });
                        }
                    }
                }
            }
            return products;
        }




    }
}
