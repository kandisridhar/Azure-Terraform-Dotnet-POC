# Create Public IP Address
resource "azurerm_public_ip" "mypublicip" {
  name                = var.pip_name
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  allocation_method   = "Static"
  domain_name_label = "vm-app-test1"
  tags = {
    environment = "test"
  }
}


# Create Network Interface
resource "azurerm_network_interface" "myvmnic" {
  name                = var.nic_name
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    # subnet_id                     = azurerm_subnet.mysubnet[0].id
    subnet_id = module.vnet-module.subnet_name0
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.mypublicip.id 
  }
  tags = {
    environment = "test"
  }

  depends_on = [module.vnet-module.vnet_name] 
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app_SecurityGroup"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_network_security_rule" "example" {
  name                        = "Allports_security_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}
resource "azurerm_network_security_rule" "example1" {
  name                        = "5985_security_rule"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5985"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}
resource "azurerm_network_security_rule" "example2" {
  name                        = "5986_security_rule"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "example3" {
  name                        = "443_security_rule"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myvmnic.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}
resource "azurerm_windows_virtual_machine" "app_vm" {
  name                = var.appvm
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  size                = "Standard_DS1_v2"
  admin_username      = "demousr"
  admin_password      = "Azure@123"
  network_interface_ids = [
    azurerm_network_interface.myvmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  /*provisioner "file" {
      connection {
        type = "winrm"
        user = "demousr"
        password = "Azure@123"
        port = 5986
        insecure = true
        use_ntlm = true
        https       = true
        timeout     = "5m"
        host = azurerm_network_interface.myvmnic.private_ip_address
      }
      source = "C:/Users/sridhar/Desktop/Azure-task2/Azure-Terraform-test/ProductApp/ProductApp/bin/Debug/netcoreapp3.1/publish"
      destination = "C:/Samplewebapp/publish"
  }*/
  
  depends_on = [
    azurerm_network_interface.myvmnic
  ]

  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.app_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell Add-WindowsFeature Web-Asp-Net45;Add-WindowsFeature NET-Framework-45-Core;Add-WindowsFeature Web-Net-Ext45;Add-WindowsFeature Web-ISAPI-Ext;Add-WindowsFeature Web-ISAPI-Filter;Add-WindowsFeature Web-Mgmt-Console;Add-WindowsFeature Web-Scripting-Tools;Add-WindowsFeature Search-Service;Add-WindowsFeature Web-Filtering;Add-WindowsFeature Web-Basic-Auth;Add-WindowsFeature Web-Windows-Auth;Add-WindowsFeature Web-Default-Doc;Add-WindowsFeature Web-Http-Errors;Add-WindowsFeature Web-Static-Content;[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3;[Net.ServicePointManager]::SecurityProtocol = 'Tls, Tls11, Tls12, Ssl3';$temp_path = 'D:/';$whb_installer_url = 'https://download.visualstudio.microsoft.com/download/pr/fa3f472e-f47f-4ef5-8242-d3438dd59b42/9b2d9d4eecb33fe98060fd2a2cb01dcd/dotnet-hosting-3.1.0-win.exe';$whb_installer_file = $temp_path + [System.IO.Path]::GetFileName( $whb_installer_url );Invoke-WebRequest -Uri $whb_installer_url -OutFile $whb_installer_file;Set-Location -Path 'D:/';Powershell.exe  ./dotnet-hosting-3.1.0-win.exe -DeploymentType 'Install' -DeployMode 'Silent'"
    }
SETTINGS
}

/*resource "azurerm_firewall" "region1-fw01" {
  name                = "region1-fw01"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  sku_tier = "Standard"
  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = module.vnet-module.subnet_name0
    public_ip_address_id = azurerm_public_ip.mypublicip.id
  }
}

#Firewall Policy
resource "azurerm_firewall_policy" "region1-fw-pol01" {
  name                = "region1-firewall-policy01"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
}

# Firewall Policy Rules
resource "azurerm_firewall_policy_rule_collection_group" "region1-policy1" {
  name               = "region1-policy1"
  firewall_policy_id = azurerm_firewall_policy.region1-fw-pol01.id
  priority           = 100
  /*application_rule_collection {
    name     = "blocked_websites1"
    priority = 500
    action   = "Deny"
    rule {
      name = "dodgy_website"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["jakewalsh.co.uk"]
    }
  }*/
  /*network_rule_collection {
    name     = "network_rules1"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}*/
/*
resource "azurerm_virtual_machine_extension" "vm_extension_install_dotnet" {
  name                       = "InstallDotNet"
  virtual_machine_id         = azurerm_windows_virtual_machine.app_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings                   = <<SETTINGS
    {
      "fileUris": [
        "https://appstoragetest6789.blob.core.windows.net/dotnet48/dotnet-install.ps1"
      ],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File dotnet-install.ps1 && powershell -NoProfile -ExecutionPolicy unrestricted -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Runtime dotnet -Channel 2.1 -InstallDir 'C:\\Program Files\\dotnet' \" && powershell -NoProfile -ExecutionPolicy unrestricted -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Runtime dotnet -Channel 3.1 -InstallDir 'C:\\Program Files\\dotnet' \""
    }
    SETTINGS

    depends_on = [
    azurerm_storage_container.storage_container1
  ]
}*/

/*resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.app_vm.id
   // publisher                  = "Microsoft.Compute"
  publisher =  "Microsoft.Azure.Extensions"
  //type                       = "CustomScriptExtension"
  type = "CustomScript" 
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    
    {
      
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools",
      "commandToExecute": "powershell Add-WindowsFeature Web-Asp-Net45;Add-WindowsFeature NET-Framework-45-Core;Add-WindowsFeature Web-Net-Ext45;Add-WindowsFeature Web-ISAPI-Ext;Add-WindowsFeature Web-ISAPI-Filter;Add-WindowsFeature Web-Mgmt-Console;Add-WindowsFeature Web-Scripting-Tools;Add-WindowsFeature Search-Service;Add-WindowsFeature Web-Filtering;Add-WindowsFeature Web-Basic-Auth;Add-WindowsFeature Web-Windows-Auth;Add-WindowsFeature Web-Default-Doc;Add-WindowsFeature Web-Http-Errors;Add-WindowsFeature Web-Static-Content;"
    }
SETTINGS
}*/

/*resource "azurerm_virtual_machine_extension" "vm_dotnet_install" {
  name                       = "vm_dotnet_install"
  virtual_machine_id         = azurerm_windows_virtual_machine.app_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    
    {
      "fileUris": [
        "https://yourblobstorageaccount.blob.core.windows.net/dotnet48/InstallDotNet-48.ps1"
      ],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File InstallDotNet-48.ps1 && powershell -NoProfile -ExecutionPolicy unrestricted -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Runtime dotnet -Channel 2.1 -InstallDir 'C:\\Program Files\\dotnet' \" && powershell -NoProfile -ExecutionPolicy unrestricted -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Runtime dotnet -Channel 3.1 -InstallDir 'C:\\Program Files\\dotnet' \""
    }
SETTINGS
}*/

/*resource "null_resource" "application_setup" {
  depends_on=[
    azurerm_windows_virtual_machine.app_vm
  ]
  provisioner "remote-exec" {
      command = "/bin/bash script.sh"
  }
  
}*/
