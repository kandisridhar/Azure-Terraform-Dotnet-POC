/*
# Create Virtual Network
resource "azurerm_virtual_network" "myvnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  
  tags = {
    environment = "test"
  }

   depends_on = [azurerm_resource_group.myrg] 
}
# Create Subnet
resource "azurerm_subnet" "mysubnet" {
  count = length(var.subnet_names)
  name  = var.subnet_names[count.index]
  address_prefixes     = [var.subnet_prefixes[count.index]]
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  
  service_endpoints = ["Microsoft.Sql"]

  depends_on = [azurerm_virtual_network.myvnet] 
}
*/