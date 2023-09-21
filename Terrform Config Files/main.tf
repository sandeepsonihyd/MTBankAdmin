terraform {
   required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.73.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}
provider "azurerm" { 
    subscription_id = "24784a25-4b3b-4fbe-bd67-045821454fda"
    client_id = "c259f715-168c-4ad5-a3b5-7a3f4a290af7"
    client_secret = "oB68Q~eLq_QfyzRAKASyNNOmwCxEG~I9fqNYhayL"
    tenant_id = "82d8af3b-d3f9-465c-b724-0fb186cc28c7"
    features {}
}
#Creating a Resource Group
# resource "azurerm_resource_group" "my" { 
#   name     = "Sandeep-Terraform-rg"
#   location = "east us"
# }
