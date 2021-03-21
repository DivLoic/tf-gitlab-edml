resource "google_compute_instance" "gitlab" {
  name                      = "gitlab"
  zone                      = var.gcp_zone
  machine_type              = "n1-standard-2"
  project                   = var.gcp_project
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.gitlab-server-startup.rendered

  tags = ["gitlab"]

  metadata = {
    gce-container-declaration = module.gitlab_container_config.metadata_value
  }

  labels = {
    container-vm = module.gitlab_container_config.vm_container_label
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  network_interface {
    network    = google_compute_network.gitlab.name
    subnetwork = google_compute_subnetwork.gitlab-subnet.self_link
    access_config {
      network_tier = "STANDARD"
    }
  }

  attached_disk {
    mode        = "READ_WRITE"
    device_name = var.compute_disk
    source      = "projects/${var.gcp_project}/zones/${var.gcp_zone}/disks/${var.compute_disk}"
  }

  boot_disk {

    initialize_params {
      type  = "pd-standard"
      image = module.gitlab_container_config.source_image
    }
  }
}

resource "google_compute_instance_group" "gitlab" {
  name = "gitlab-group"
  zone = "europe-west1-b"
  instances = [
    google_compute_instance.gitlab.self_link
  ]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "gitlab" {
  name = "gitlab-http-health-check"

  healthy_threshold   = 1
  timeout_sec         = 120
  check_interval_sec  = 300
  unhealthy_threshold = 10


  http_health_check {
    port         = "80"
    request_path = "/help/"
  }
}

resource "google_compute_backend_service" "gitlab" {

  name        = "gitlab-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 120

  backend {
    group = google_compute_instance_group.gitlab.self_link
  }
  health_checks = [
    google_compute_health_check.gitlab.self_link
  ]
}

resource "google_compute_url_map" "gitlab" {
  name            = "gitlab-url-map"
  default_service = google_compute_backend_service.gitlab.self_link
}

resource "google_compute_firewall" "gitlab" {

  name    = "gitlab-firewall"
  network = google_compute_network.gitlab.self_link
  allow {

    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["gitlab"]
  source_ranges = concat(
  data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal,
  [google_compute_subnetwork.gitlab-subnet.ip_cidr_range]
  )
}

resource "google_compute_target_http_proxy" "gitlab" {
  count = var.secure ? 0 : 1

  name = "gitlab-https-proxy"
  url_map = google_compute_url_map.gitlab.self_link
}

resource "google_compute_target_https_proxy" "gitlab" {
  count = var.secure ? 1 : 0

  name    = "gitlab-https-proxy"
  url_map = google_compute_url_map.gitlab.self_link

  ssl_certificates = [
    data.google_compute_ssl_certificate.gitlab-cert[0].self_link
  ]
}

resource "google_compute_global_forwarding_rule" "gitlab" {

  name       = "gitlab-frontend"
  port_range = var.secure ? "443" : "80"
  target = (var.secure ?
  google_compute_target_https_proxy.gitlab[0].self_link :
  google_compute_target_http_proxy.gitlab[0].self_link)
  ip_address = (var.secure ? data.google_compute_global_address.gitlab-ip[0].self_link: null)
}