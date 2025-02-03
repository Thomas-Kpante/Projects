using System;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;

namespace LabMVC.Models
{
    class ClientDAO
    {
        private readonly string connectionString = "Data Source=(local)\\SQLEXPRESS;Initial Catalog=Ecommerce;Integrated Security=True;";

        private DbProviderFactory df;
        private DbConnection cn;
        private DbCommand cmdCommand;

        public ClientDAO()
        {
            df = DbProviderFactories.GetFactory("System.Data.SqlClient");
            cn = df.CreateConnection();

            try
            {
                cn.ConnectionString = connectionString;
                cn.Open();
                cmdCommand = df.CreateCommand();
                cmdCommand.Connection = cn;
            }
            catch (SqlException e)
            {
                Console.WriteLine("Erreur de connexion, exception: " + e.StackTrace.ToString());
            }
        }

        public int SaveClient(ClientVO client)
        {
            int clientId = 0;
            string commandText = "INSERT INTO Client (FullName, PhoneNumber, Email) OUTPUT INSERTED.ClientID VALUES (@FullName, @PhoneNumber, @Email);";

            try
            {
                if (cmdCommand.Connection.State != ConnectionState.Open)
                {
                    cmdCommand.Connection.Open();
                }

                cmdCommand.Parameters.Clear();

                var fullNameParam = cmdCommand.CreateParameter();
                fullNameParam.ParameterName = "@FullName";
                fullNameParam.Value = client.FullName;
                cmdCommand.Parameters.Add(fullNameParam);

                var phoneNumberParam = cmdCommand.CreateParameter();
                phoneNumberParam.ParameterName = "@PhoneNumber";
                phoneNumberParam.Value = client.PhoneNumber;
                cmdCommand.Parameters.Add(phoneNumberParam);

                var emailParam = cmdCommand.CreateParameter();
                emailParam.ParameterName = "@Email";
                emailParam.Value = client.Email;
                cmdCommand.Parameters.Add(emailParam);

                cmdCommand.CommandText = commandText;
                clientId = (int)cmdCommand.ExecuteScalar();
            }
            catch (Exception e)
            {
                Console.WriteLine("An error occurred while saving the client: " + e.Message);
            }
            

            return clientId;
        }

        public int GetClientIdByFullName(string fullName)
        {
            int clientId = 0;
            try
            {
                if (cmdCommand.Connection.State != ConnectionState.Open)
                {
                    cmdCommand.Connection.Open();
                }

                cmdCommand.Parameters.Clear();
                cmdCommand.CommandText = "SELECT ClientID FROM Client WHERE FullName = @FullName;";

                // Create a parameter and add it to the command
                var fullNameParam = cmdCommand.CreateParameter();
                fullNameParam.ParameterName = "@FullName";
                fullNameParam.Value = fullName;
                cmdCommand.Parameters.Add(fullNameParam);

                var result = cmdCommand.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    clientId = Convert.ToInt32(result);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("An error occurred while retrieving the client ID: " + e.Message);
            }
           

            return clientId;
        }

    }
}
