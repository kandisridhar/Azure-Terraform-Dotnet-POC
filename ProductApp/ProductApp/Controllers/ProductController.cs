using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

namespace ProductApp.Controllers
{
    public class ProductController : Controller
    {
        private readonly ProductService _product_service;
        public ProductController(ProductService _svc)
        {
            _product_service = _svc;
        }

        // The Index method is used to get a list of courses and return it to the view
        public IActionResult Index()
        {
            IEnumerable<Product> _product_list = _product_service.GetProducts();
            return View(_product_list);
        }

    }
}
