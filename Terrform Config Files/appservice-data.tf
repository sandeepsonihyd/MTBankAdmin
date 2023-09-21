# resource "azurerm_resource_group" "terraform-rg" {
#   name     = "sandeep-terraform-rg"
#   location = "eastus"
# }

data "azurerm_resource_group" "terraform-rg" {
  name = "Terraform-demo-rg"
}

# resource "azurerm_service_plan" "demo-appservice-plan" {
#   name                = "sandeep-demo-appservice-plan"
#   location            = azurerm_resource_group.terraform-rg.location
#   resource_group_name = azurerm_resource_group.terraform-rg.name
#   os_type             = "Linux"
#   sku_name         = "B2"
# }
data "azurerm_service_plan" "demo-appservice-plan" {
  name                = "DemoAppService-plan"
  resource_group_name = data.azurerm_resource_group.terraform-rg.name
}

resource "azurerm_linux_web_app" "demo-appservice" {
  name                = "sandeep-demo-appservice"
  location            = data.azurerm_resource_group.terraform-rg.location
  resource_group_name = data.azurerm_resource_group.terraform-rg.name
  service_plan_id = data.azurerm_service_plan.demo-appservice-plan.id

  site_config {
    application_stack {
      dotnet_version = "7.0"
    }
    always_on = false
  }
  app_settings = {
    "Setting1" = "Value1"
    "Setting2" = "Value2"
  }
  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}