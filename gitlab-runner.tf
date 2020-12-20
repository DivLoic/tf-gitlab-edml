resource "google_compute_instance" "gitlab-runner" {

  name                      = "gitlab-runner"
  zone                      = "europe-west1-b"
  machine_type              = "n1-standard-2"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.gitlab-runner-startup.rendered
  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["gitlab-runner"]

  network_interface {
    network    = google_compute_network.gitlab.self_link
    subnetwork = google_compute_subnetwork.gitlab-subnet.self_link
    access_config {}
  }
  boot_disk {
    initialize_params {
      size  = 50
      image = "ubuntu-1804-bionic-v20191002"
    }
  }

  metadata = {
    shutdown-script = data.template_file.gitlab-runner-shutdown.rendered
  }
}