resource "google_compute_network" "gitlab" {
  name                    = "gitlab"
  project                 = var.gcp_project
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "gitlab-subnet" {
  network       = google_compute_network.gitlab.name
  name          = "gitlab-subnet"
  project       = var.gcp_project
  region        = var.gcp_region
  ip_cidr_range = "10.0.4.0/28"
  // TODO: set this correctly
}

resource "google_compute_firewall" "main-ssh-access" {
  name    = "gitlab-ssh-firewall"
  project = var.gcp_project
  network = google_compute_network.gitlab.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = [
    //"gitlab-runner"
  ]
}

resource "google_compute_firewall" "gitlab-ssh" {
  name    = "git-client-firewall"
  network = google_compute_network.gitlab.name
  allow {
    protocol = "tcp"
    ports    = ["2222"] // "9418" ?
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [
    // "gitlab"
  ]
}