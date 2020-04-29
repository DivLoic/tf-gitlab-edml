resource "google_compute_instance_from_template" "gitlab" {

  name         = "gitlab"
  zone         = "europe-west1-b"
  machine_type = "n1-standard-1"
  network_interface {
    network    = google_compute_network.gitlab.self_link
    subnetwork = google_compute_subnetwork.gitlab-subnet.self_link
    access_config {
      nat_ip = data.google_compute_address.gitlab-scm-ip.address
    }
  }
  attached_disk {
    source      = "projects/event-driven-ml/zones/europe-west1-b/disks/gitlab-disk"
    mode        = "READ_WRITE"
    device_name = "gitlab-disk"
  }
  source_instance_template = "projects/event-driven-ml/global/instanceTemplates/gitlab-template-8"

  tags = ["gitlab"]
}
resource "google_compute_instance_group" "gitlab" {
  name = "gitlab-group"
  zone = "europe-west1-b"
  instances = [
    "${google_compute_instance_from_template.gitlab.self_link}"
  ]

  # startup script
  # sudo mkdir -p /mnt/disks/gitlab-disk
  # sudo chmod a+w /mnt/disks/gitlab-disk
  # sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
  # sudo mount -o discard,defaults /dev/sdb /mnt/disks/gitlab-disk
}

resource "google_compute_health_check" "gitlab" {
  name = "gitlab-http-health-check"

  healthy_threshold   = 1
  timeout_sec         = 120
  check_interval_sec  = 300
  unhealthy_threshold = 10


  http_health_check {
    port         = "80"
    request_path = "/users/sign_in/"
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

resource "google_compute_target_https_proxy" "gitlab" {
  name    = "gitlab-http-proxy"
  url_map = google_compute_url_map.gitlab.self_link

  ssl_certificates = [
    data.google_compute_ssl_certificate.gitlab-cert.self_link
  ]
}

resource "google_compute_global_forwarding_rule" "gitlab" {

  name       = "gitlab-frontend"
  port_range = "443"
  target     = google_compute_target_https_proxy.gitlab.self_link
  ip_address = data.google_compute_global_address.gitlab-ip.self_link
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