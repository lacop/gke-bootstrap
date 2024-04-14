# NAT router for egress traffic.
# Needed to pull images, but could be disabled if using exclusively GCP Artifact Registry.

resource "google_compute_router" "router" {
    name = "nat-router"
    project = google_compute_subnetwork.default.project
    region = google_compute_subnetwork.default.region
    network = google_compute_network.default.id
}

resource "google_compute_router_nat" "nat" {
    name = "nat-router-nat"
    router = google_compute_router.router.name
    region = google_compute_router.router.region
    project = google_compute_router.router.project
    nat_ip_allocate_option = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}