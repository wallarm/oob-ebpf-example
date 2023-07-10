output "cluster_name" {
    value = azurerm_kubernetes_cluster.aks.name
}

output "rg_name" {
    value = azurerm_resource_group.main.name
}
