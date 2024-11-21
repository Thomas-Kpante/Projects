using System;
using System.Collections.Generic;

namespace LabMVC.Models
{
    public class OrderVO
    {
        public int OrderID { get; set; }
        public int ClientID { get; set; }
        public DateTime OrderDate { get; set; }
        public string ShippingAddress { get; set; }
        public decimal TotalAmount { get; set; }

        // Client details
        public string FullName { get; set; }
        public string PhoneNumber { get; set; }
        public string Email { get; set; }

        // Total quantity of items in the order
        public int TotalQuantity
        {
            get
            {
                int total = 0;
                foreach (var item in OrderItems)
                {
                    total += item.Quantity;
                }
                return total;
            }
        }

   
        public List<OrderItemVO> OrderItems { get; set; }
    }
}
