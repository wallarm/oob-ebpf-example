resource "kubectl_manifest" "main" {
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    helm_release.ingress_nginx,
    kubernetes_namespace.app,
    kubernetes_secret.app
  ]
  for_each = fileset("../manifests", "*.yaml")
  yaml_body = file("../manifests/${each.value}")
}
