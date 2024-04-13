variable "project_id" {
    description = "GCP project ID"
}

variable "region" {
    description = "GCP region"
}

variable "zone" {
    description = "GCP zone"
}

variable "gke_cluster_name" {
    description = "GKE cluster name"
}

variable "num_nodes" {
    description = "Number of nodes in the GKE cluster"
}

variable "machine_type" {
    description = "Machine type for the GKE cluster nodes"
}

variable "disk_size" {
    description = "Disk size for the GKE cluster nodes"
}
