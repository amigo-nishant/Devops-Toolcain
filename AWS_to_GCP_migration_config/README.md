To run the shell script command

**source ./keys/env.key && bash GKE_cluster_commission.sh cluster_name env_name**


Create a service account which has required previlages to privision the GKS cluster and assign it to terraform.


Create a service account and assign respective roles to it so that nodes in the cluster can use it for inetrnal communication.


Create a custom VPC to deploy the private cluster

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "true"
}


Create a private instance of Google Kubernetes Cluster with public endpoint and master authorization enabled

resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
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
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  autoscaling {
    min_node_count = "1"
    max_node_count = "2"
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
    image_type   = "cos_containerd"
    machine_type = "e2-standard-2"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
       service_account = google_service_account.cluster-serviceaccount.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}



Create Cloud NAT configuration

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.0"
  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = "${var.project_id}-nat-config"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


Create a router configuration

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${var.project_id}-nat-router"
  network = google_compute_network.vpc.name
  region  = var.region
}


Post successful deploy, connect to the cluster and validate
Build the container.
Push the container to the google container registry.
Terraform Commands --
terraform init

This command will initialize the terraform in that folder.
Also initialize provider plugins, in our case it could download plugins which is relevant to AWS.
You don’t need to run this command every time

terraform validate

To verify if your code does not have any syntax errors.

terraform plan

This command can help you to understand what actions will be performed when your trigger the terraform file.

terraform apply

This command will do actual implementation in your infrastructure.

terraform destroy

This command will destroy the infrastructure as described in your terraform file.

Refernces

a.  https://github.com/gruntwork-io/terraform-google-gke/blob/v0.10.0/examples/gke-private-cluster/main.tf

b.  https://github.com/hashicorp/learn-terraform-provision-gke-cluster/blob/main/gke.tf

c.  https://github.com/gruntwork-io/terraform-google-gke/blob/v0.10.0/modules/gke-service-account/main.tf

d.  https://medium.comthe-telegraph-engineeringbinding-gcp-accounts-to-gke-service-accounts-with-terraform-dfca4e81d2a0

e.  https://medium.com/google-cloud/gcp-terraform-to-deploy-private-gke-cluster-bebb225aa7be

f.  https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke
