provider "google" {
    project = var.project_id
    region  = var.region
}

resource "google_container_cluster" "default" {
    provider = google
    project  = var.project_id
    name     = var.gke_cluster_name
    location = var.zone

    initial_node_count = var.num_nodes

    networking_mode = "VPC_NATIVE"
    
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

    master_authorized_networks_config {
        cidr_blocks {
            cidr_block = "0.0.0.0/0"
            display_name = "Allow all"
        }
    }
}