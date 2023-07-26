# Copyright (c) HashiCrp, Inc.
# SPDX-License-Identifier: MPL-2.0
#terraform {
#  backend "gcs" {
#      bucket = "akash-test-bucket-terraform"
#  }
#}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block

}

ip_allocation_policy {
  }
dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = lookup(cidr_blocks.value, "display_name", null)
        }
      }
    }
  }
}

#Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  node_locations = var.node_locations
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  autoscaling {
    min_node_count = var.min_node
    max_node_count = var.max_node
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }
  node_config {

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    image_type   = var.image_type
    machine_type = var.machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
        #service_account = google_service_account.cluster-serviceaccount.email
        service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# resource "google_service_account" "cluster-serviceaccount" {
#  account_id   = "cluster-serviceaccount"
#  display_name = "Service Account For Terraform To Make GKE Cluster"
# }

# resource "google_project_iam_member" "storage-role" {
#  role = "roles/container.admin"
#  project = var.project_id
#  member = "serviceAccount:${google_service_account.cluster-serviceaccount.email}"
#}

# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

