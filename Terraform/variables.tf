# Input Variables
variable "resoure_group_name" {
  description = "Resource Group Name"
  type = string
  default = "myrg--test"
}

variable "resoure_group_location" {
  description = "Resource Group Location"
  type = string
  default = "centralindia"
}

variable "pip_name" {
  description = "VM public Ip"
  type = string 
  default = "vmpublicip-test"
}

variable "nic_name" {
  description = "Network Interface card"
  type = string 
  default = "nic_name-test"
}

variable "appvm" {
  description = "VM Name"
  type = string 
  default = "appvm-test1"
}

variable "sqlserver-name" {
  description = "VM Name"
  type = string 
  default = "appserver60080890"
}


variable "sqldb-name" {
  description = "VM Name"
  type = string 
  default = "appdb"
}

variable "storage_name" {
  description = "Storage Account Name"
  type = string 
  default = "appstoragetest6789"
}

variable "storage_container_name" {
  description = "Storage Account Container Name"
  type = string 
  default = "appstoragecontainer"
}

variable "Productapp" {
  description = "Storage Account Container Name"
  type = string 
  default = "Productapp.rar" # Blob Name must contain file extention like .rar/.zip/.jpg
}