provider "google" {
    project = var.project_id
    region  = var.region
}

data "google_client_config" "provider" {}

resource "google_container_cluster" "default" {
    provider = google
    project  = var.project_id
    name     = var.gke_cluster_name
    location = var.zone

    initial_node_count = var.num_nodes

    networking_mode = "VPC_NATIVE"
    network = google_compute_network.default.name
    subnetwork = google_compute_subnetwork.default.name
    
    logging_service = "none"

    node_config {
        spot = true
        machine_type = var.machine_type
        disk_size_gb = var.disk_size
        tags = ["${var.gke_cluster_name}"]
        oauth_scopes = [
            # TODO: Review and update.
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/trace.append"
        ]
    }

    addons_config {
        http_load_balancing {
            disabled = false
        }
    }

    private_cluster_config {
        enable_private_nodes = true
        enable_private_endpoint = false
        master_ipv4_cidr_block = "172.16.0.16/28"
    }

    # TODO: Research and enable?
    # default_snat_status {
    #     # More info on why sNAT needs to be disabled: https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#enable_pupis
    #     # This applies to VPC-native GKE clusters
    #     disabled = true
    # }

    master_authorized_networks_config {
        cidr_blocks {
            cidr_block = "0.0.0.0/0"
            display_name = "Allow all"
        }
    }
}

resource "google_compute_network" "default" {
    name = var.network_name
    auto_create_subnetworks = false
    project = var.project_id
    routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "default" {
    depends_on = [google_compute_network.default]
    name = "${var.network_name}-subnet"
    project = google_compute_network.default.project
    region = var.region
    network = google_compute_network.default.name
    ip_cidr_range = "10.0.0.0/24"
}