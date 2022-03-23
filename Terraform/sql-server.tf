
# SQL Server Creation
resource "azurerm_sql_server" "app_server_6008089" {
  name                = var.sqlserver-name
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name  
  version             = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Azure@123"

  tags = {
    environment = "test"
  }
}

resource "azurerm_sql_database" "app_db" {
  name                = var.sqldb-name
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name  
  server_name         = azurerm_sql_server.app_server_6008089.name
   depends_on = [
     azurerm_sql_server.app_server_6008089
   ]
}

resource "azurerm_sql_firewall_rule" "app_server_firewall_rule_Azure_services" {
  name                = "app-server-firewall-rule-Allow-Azure-services"
  resource_group_name = azurerm_resource_group.myrg.name
  server_name         = azurerm_sql_server.app_server_6008089.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  depends_on=[
    azurerm_sql_server.app_server_6008089
  ]
}

resource "azurerm_sql_firewall_rule" "app_server_firewall_rule_Client_IP" {
  name                = "app-server-firewall-rule-Allow-Client-IP"
  resource_group_name = azurerm_resource_group.myrg.name
  server_name         = azurerm_sql_server.app_server_6008089.name
  start_ip_address    = "49.37.0.0"
  end_ip_address      = "49.37.255.255"
  depends_on=[
    azurerm_sql_server.app_server_6008089
  ]
}
resource "null_resource" "database_setup" {
  depends_on=[
    azurerm_sql_server.app_server_6008089,
    azurerm_sql_database.app_db,
    azurerm_sql_firewall_rule.app_server_firewall_rule_Azure_services,
    azurerm_sql_firewall_rule.app_server_firewall_rule_Client_IP
  ]
  provisioner "local-exec" {
      command = "sqlcmd -S appserver60080890.database.windows.net -U sqladmin -P Azure@123 -d appdb -i init.sql"
  }
  
}

resource "azurerm_sql_virtual_network_rule" "sqlvnetrule" {
  name                = "sql-vnet-rule"
  resource_group_name = azurerm_resource_group.myrg.name
  server_name         = azurerm_sql_server.app_server_6008089.name
  subnet_id           = module.vnet-module.subnet_name1
}