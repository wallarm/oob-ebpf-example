resource "helm_release" "cm" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.12.0"
  wait       = true
  set {
    name  = "installCRDs"
    value = true
  }
  create_namespace = true
}

resource "helm_release" "oob" {
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    helm_release.cm
  ]
  name       = "oob-ebpf"
  repository = "https://charts.wallarm.com"
  chart      = "wallarm-oob"
  namespace  = "oob-ebpf"
  values     = [file("../helm-values/oob-ebpf.yaml")]
  wait       = true

  set {
    name  = "config.api.host"
    value = var.wallarm_api_host
  }

  set_sensitive {
    name  = "config.api.token"
    value = var.wallarm_api_token
  }

  create_namespace = true
}

resource "helm_release" "ingress_nginx" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.5.2"
  values     = [file("../helm-values/ingress.yaml")]

  create_namespace = true
}

resource "helm_release" "prometheus" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "prometheus"
  values     = [yamlencode({
    "kube-state-metrics" = {
      "enabled" = true
    },
    "prometheus-pushgateway" = {
      "enabled" = false
    },
    "alertmanager" = {
      "enabled" = false
    }
  })]

  create_namespace = true
}

resource "helm_release" "grafana" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "grafana"
  values     = [yamlencode({
    "adminUser" = "admin",
    "adminPassword" = "admin",
    "datasources" = {
      "datasources.yaml" = {
        apiVersion = 1,
        "datasources" = [{
            "name"      = "Prometheus",
            "type"      = "prometheus"
            "url"       = "http://prometheus-server.prometheus.svc",
            "isDefault" = true
        }]
      }

      #    - name: Prometheus
      #      type: prometheus
      #      url: http://prometheus-prometheus-server
      #      access: proxy
      #      isDefault: true
    }
  })]

  create_namespace = true
}
