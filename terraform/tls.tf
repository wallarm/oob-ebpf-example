resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
  }
}

resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca_crt" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name = var.app_host
  }

  validity_period_hours = 5 * 365 * 24 # 5 years

  allowed_uses = [
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "data_encipherment",
    "cert_signing",
    "crl_signing",
    "ocsp_signing",
    "any_extended",
  ]

  is_ca_certificate = true
}

resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "server_csr" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name         = var.app_host
    organization        = "Wallarm, Inc"
    organizational_unit = "Engineering"
  }

  dns_names = [
    var.app_host
  ]

}

resource "tls_locally_signed_cert" "server_crt" {
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_crt.cert_pem

  cert_request_pem = tls_cert_request.server_csr.cert_request_pem

  validity_period_hours = (5 * 365 * 24) - 1

  allowed_uses = [
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "data_encipherment",
    "server_auth",
    "client_auth",
    "timestamping",
  ]
}

resource "kubernetes_secret" "app" {
  metadata {
    name      = "httpbin"
    namespace = var.app_namespace
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.server_crt.cert_pem
    "tls.key" = tls_private_key.server_key.private_key_pem
    "ca.crt"  = tls_self_signed_cert.ca_crt.cert_pem
  }

  type = "kubernetes.io/tls"
}
