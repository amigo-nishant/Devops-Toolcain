# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "google" {
  project = var.project_id
  region  = var.region
 # credentials = file(var.auth_file)
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.cluster_name}"
  auto_create_subnetworks = "true"
}

