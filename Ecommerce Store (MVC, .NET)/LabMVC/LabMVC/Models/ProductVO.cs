using System;

namespace LabMVC.Models
{
    public class ProductVO
    {
        public int ProductID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }

        public string CategoryID { get; set; }
        public string ImageURL { get; set; }
        


    }
}
