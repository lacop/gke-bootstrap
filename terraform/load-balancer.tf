resource "google_compute_address" "default" {
    name = var.ip_address_name
    project = var.project_id
    region = var.region
    network_tier = "STANDARD"
}