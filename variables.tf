variable "gcp_project" {
  type = string
  description = "Google Cloud Project hosting the Gitlab deployment"
}

variable "gcp_region" {
  type = string
  default = "europe-west1"
  description = "Google Cloud Platform region for hosting Gitlab"
}

variable "gcp_zone" {
  type = string
  default = "europe-west1-b"
  description = "Google Cloud Platform zone for hosting Gitlab"
}

variable "service_account_id" {
  type = string
  description = "SA used to manage gitlab/gitlab runners resources"
}

variable "gcs_bucket" {
  type = string
  description = "Permanent bucket containing tf state, disk backup, certificate etc..."
}

variable "compute_disk" {
  type = string
  description = "Permanent disk used as mounting point for the gitlab server container"
}

variable "cos_disk_mnt_path" {
  type = string
  default = "/mnt/disks/gce-containers-mounts/gce-persistent-disks"
  description = "Path used to mount compute engine disk"
}

variable "secure" {
  type = bool
  default = false
  description = ""
}