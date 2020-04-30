provider "google" {
  alias = "token-access"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

data "google_service_account" "tf_account" {
  provider = google.token-access
  project    = var.gcp_project
  account_id = var.service_account_id
}

data "google_service_account_access_token" "default" {
  provider = google.token-access
  target_service_account = data.google_service_account.tf_account.email
  scopes = [
    "userinfo-email",
    "cloud-platform"
  ]
  lifetime = "3000s"
}

data "google_compute_zones" "available" {
  project = var.gcp_project
  region  = var.gcp_region
}

data "google_compute_ssl_certificate" "gitlab-cert" {
  name = "gitlab-cert"
}

data "google_compute_global_address" "gitlab-ip" {
  name = "gitlab-ip"
}

data "google_compute_address" "gitlab-scm-ip" {
  name = "gitlab-scm-ip"
}

data "google_compute_lb_ip_ranges" "ranges" {}

data "template_file" "gitlab-runner-config" {
  template = file("${path.module}/resources/config.toml")
}

data "template_file" "gitlab-runner-shutdown" {
  template = file("${path.module}/resources/gitlab-runner-shutdown.sh")
  vars = {
    JSON_KEY_ID = "$${JSON_KEY_ID}"
  }
}

data "template_file" "gitlab-runner-startup" {
  template = file("${path.module}/resources/gitlab-runner-startup.sh")

  vars = {
    # VERSION="1.5.0"
    # OS="linux"  # or "darwin" for OSX, "windows" for Windows.
    # ARCH="amd64"  # or "386" for 32-bit OSs
    # DL_LINK="https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/"
    # ACCESS_KEY = data.template_file.access-key.rendered
    RUNNER_CONFIG = data.template_file.gitlab-runner-config.rendered
  }
}
