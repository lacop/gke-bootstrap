resource "google_compute_address" "default" {
    name = var.ip_address_name
    project = google_compute_subnetwork.default.project
    region = google_compute_subnetwork.default.region
    network_tier = "STANDARD"
}

resource "google_compute_region_backend_service" "default" {
    depends_on = [ helm_release.gloo, null_resource.delete_ingressgateway ]
    project = google_compute_subnetwork.default.project
    region = google_compute_subnetwork.default.region
    name = "l7-xlb-backend-service-http"
    protocol = "HTTP"
    timeout_sec = 30

    load_balancing_scheme = "EXTERNAL_MANAGED"
    health_checks = [ google_compute_region_health_check.default.id ]

    backend {
        group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${var.zone}/networkEndpointGroups/ingressgateway"
        balancing_mode = "RATE"
        capacity_scaler = 1
        max_rate_per_endpoint = 3500
    }

    circuit_breakers {
      max_retries = 10
    }

    outlier_detection {
      consecutive_errors = 2
      base_ejection_time {
        seconds = 30
      }
      interval {
        seconds = 1
      }
      max_ejection_percent = 50
    }
}

# TODO: Can we declare google_compute_network_endpoint_group instead of this?
resource "null_resource" "delete_ingressgateway" {
    provisioner "local-exec" {
        when = destroy
        command = "gcloud compute network-endpoint-groups delete ingressgateway --quiet"
    }
}

resource "google_compute_region_health_check" "default" {
    depends_on = [google_compute_firewall.default]
    project = google_compute_subnetwork.default.project
    region = google_compute_subnetwork.default.region
    name = "l7-xlb-basic-check-http"
    http_health_check {
        port_specification = "USE_SERVING_PORT"
        request_path = "/"
    }
    timeout_sec = 1
    check_interval_sec = 3
    healthy_threshold = 1
    unhealthy_threshold = 1
}


resource "google_compute_firewall" "default" {
    name = "fw-allow-health-check-and-proxy"
    network = google_compute_network.default.id
    project = google_compute_network.default.project
    source_ranges = [
        # Allow for ingress from the health checks and the managed Envoy proxy. For more information, see:
        # https://cloud.google.com/load-balancing/docs/https#target-proxies
        "130.211.0.0/22",
        "35.191.0.0/16",
        # Our proxy network.
        google_compute_subnetwork.proxy.ip_cidr_range
    ]
    allow {
        protocol = "tcp"
    }
    target_tags = ["${var.gke_cluster_name}"]
    direction = "INGRESS"
}

resource "google_compute_subnetwork" "proxy" {
    depends_on = [ google_compute_network.default ]
    name = "proxy-only-subnet"
    project = google_compute_network.default.project
    region = google_compute_subnetwork.default.region
    network = google_compute_network.default.id
    purpose = "REGIONAL_MANAGED_PROXY"
    role = "ACTIVE"
    
    # Made up range that doesn't overlap with the GKE subnet.
    ip_cidr_range = "11.129.0.0/23"
}