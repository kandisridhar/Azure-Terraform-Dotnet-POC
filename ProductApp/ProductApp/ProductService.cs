using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;


namespace ProductApp
{
    public class ProductService
    {
        private static string db_connectionstring = "server=appserver60080890.database.windows.net;user=sqladmin;password=Azure@123;database=appdb";

        private SqlConnection GetConnection()
        {

            return new SqlConnection(db_connectionstring);
        }

        public IEnumerable<Product> GetProducts()
        {
            List<Product> _lst = new List<Product>();
            string _statement = "SELECT ProductID,ProductName,Quantity from Inventory;";
            SqlConnection _connection = GetConnection();

            _connection.Open();

            SqlCommand _sqlcommand = new SqlCommand(_statement, _connection);

            using (SqlDataReader _reader = _sqlcommand.ExecuteReader())
            {
                while (_reader.Read())
                {
                    Product _product = new Product()
                    {
                        ProductID = _reader.GetInt32(0),
                        ProductName = _reader.GetString(1),
                        Quantity = _reader.GetInt32(2)
                    };

                    _lst.Add(_product);
                }
            }
            _connection.Close();
            return _lst;
        }
    }

}
