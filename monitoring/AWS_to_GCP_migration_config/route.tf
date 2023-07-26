resource "google_compute_router" "router" {
  project = var.project_id
  name    = "router-${var.cluster_name}"
  network = google_compute_network.vpc.name
  region  = var.region
}
