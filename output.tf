locals {
  protocol = var.secure ? "https" : "http"
  port = split("-", google_compute_global_forwarding_rule.gitlab.port_range)[0]
  address = google_compute_global_forwarding_rule.gitlab.ip_address
}

output "gitlab_address" {
  value       = "${local.protocol}://${local.address}:${local.port}"
  description = "Gitlab web address."
}