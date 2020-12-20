variable "gcp_project" {
  type = string
  description = "Google Cloud Project hosting the Gitlab deployment"
}

variable "gcp_region" {
  type = string
  default = "europe-west1"
  description = "Google Cloud Project hosting the Gitlab deployment"
}

variable "service_account_id" {
  type = string
  description = "SA used to manage gitlab/gitlab runners resources"
}