variable "resource_group_name" {
   description = "Name of the resource group in which the resources will be created"
   default     = "Datarisk"
}

variable "location" {
   default = "eastus"
   description = "Location where resources will be created"
}

variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default = {
      environment = "datarisk"
   }
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "azureuser"
}

variable "admin_password" {
   description = "Default password for admin account"
   default = "Admin1234!"
}

variable "clientId" {
  type = string
}

variable "clientSecret" {
  type = string
}

variable "subscriptionId" {
  type = string
}

variable "tenantId" {
  type = string
}
