output "gke_cluster_name" {
    value = google_container_cluster.default.name
}

output "ip_address_name" {
    value = google_compute_address.default.name
}
