using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;

namespace LabMVC.Models
{
    public class CategoryDAO
    {
        private string connectionString = "Data Source=(local)\\SQLEXPRESS;Initial Catalog=Ecommerce;Integrated Security=True;";
        private DbProviderFactory factory;

        public CategoryDAO()
        {
           
            factory = DbProviderFactories.GetFactory("System.Data.SqlClient");
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
                    command.CommandText = "SELECT CategoryID, CategoryName, Description FROM Categories";

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            categories.Add(new CategoryVO
                            {
                                CategoryID = reader["CategoryID"].ToString(),
                                CategoryName = reader["CategoryName"].ToString(),
                                Description = reader["Description"].ToString()
                            });
                        }
                    }
                }
            }
            return categories;
        }

    
    }
}
