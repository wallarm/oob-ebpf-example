variable "subscription_id" {
  default = "ef8d68e3-3507-49d5-8672-194c86853309"
}

variable "name_prefix" {
  default = "ebpf-demo"
}

variable "location" {
  default = "East Asia"
}

variable "node_count" {
  default = 3
}

variable "vm_size" {
  default = "Standard_D4s_v3"
}

variable "kubernetes_version" {
  default = "1.26.3"
}

variable "wallarm_api_token" {}

variable "wallarm_api_host" {
  default = "api.wallarm.com"
}

variable "app_namespace" {
  default = "httpbin"
}

variable "app_host" {
  default = "ebpf-demo.com"
}