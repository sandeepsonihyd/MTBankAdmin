resource "azurerm_resource_group" "terraform-rg" {
  name     = "sandeep-terraform-rg"
  location = "eastus"
}

resource "azurerm_service_plan" "demo-appservice-plan" {
  name                = "sandeep-demo-appservice-plan"
  location            = azurerm_resource_group.terraform-rg.location
  resource_group_name = azurerm_resource_group.terraform-rg.name
  os_type             = "Linux"
  sku_name         = "B2"
}

resource "azurerm_linux_web_app" "demo-appservice" {
  name                = "sandeep-demo-appservice"
  location            = azurerm_resource_group.terraform-rg.location
  resource_group_name = azurerm_resource_group.terraform-rg.name
  service_plan_id = azurerm_service_plan.demo-appservice-plan.id

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

output "app_service_default_hostname" {
  value = azurerm_linux_web_app.demo-appservice.default_hostname
}
