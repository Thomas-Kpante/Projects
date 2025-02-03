using System;

namespace LabMVC.Models
{
    public class ClientVO
    {
        private int clientID;
        private string fullName;
        private string phoneNumber; // Note: Ensure this is securely hashed
        private string email;

        public int ClientID
        {
            get { return clientID; }
            set { clientID = value; }
        }

        public string FullName
        {
            get { return fullName; }
            set { fullName = value; }
        }

        public string PhoneNumber
        {
            get { return phoneNumber; }
            set { phoneNumber = value; } // Implement hashing or validation as necessary
        }

        public string Email
        {
            get { return email; }
            set { email = value; }
        }
    }
}
