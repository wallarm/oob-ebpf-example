locals {
  name = "${var.name_prefix}-${random_string.suffix.result}"
  tags = {
    Environment = "Test"
  }
}

resource "random_string" "suffix" {
  length      = 4
  min_numeric = 4
  special     = false
}

resource "azurerm_resource_group" "main" {
  location = var.location
  name     = local.name
}

#resource "azurerm_network_watcher" "main" {
#  name                = local.name
#  location            = azurerm_resource_group.main.location
#  resource_group_name = azurerm_resource_group.main.name
#}

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = local.name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  location            = azurerm_resource_group.main.location
  name                = local.name
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = local.name
  kubernetes_version = var.kubernetes_version
  tags                = local.tags

  public_network_access_enabled   = true
  api_server_authorized_ip_ranges = ["0.0.0.0/0"]


  default_node_pool {
    name       = "defaultpool"
    os_sku     = "Ubuntu"
    vm_size    = var.vm_size
    node_count = var.node_count
    enable_auto_scaling = false
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }
}