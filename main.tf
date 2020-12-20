provider "google" {
  version = "2.20"
  project      = var.gcp_project
  region       = var.gcp_region
  access_token = data.google_service_account_access_token.default.access_token
}
