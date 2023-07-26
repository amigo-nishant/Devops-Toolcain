variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}


variable "gke_num_nodes" {
  description = "number of gke nodes"
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation (size must be /28) to use for the hosted master network"
  type        = string
  default     = "10.5.0.0/28"

}
variable "master_authorized_networks_config" {
  description = <<EOF
  The desired configuration options for master authorized networks. Omit the nested cidr_blocks attribute to disallow external access (except the cluster node IPs, which GKE automatically whitelists)
  ### example format ###
  master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block   = "0.0.0.0/0"
      display_name = "example_network"
    }],
  }]
EOF
  type        = list(any)
  default     = []
}
variable "cluster_name" {
  description = "cluster name"
  type        = string

}

variable "image_type" {
  description = "container image type"
  type        = string
  default     = "cos_containerd"

}

variable "machine_type" {
  description = "node image type"
  type        = string
  default     = "e2-standard-2"
}

variable "node_locations" {
  description = "Zone names on which nodes will be provisioned"
  type = list(string)
}

variable "min_node" {
  description = "minimum no of nodes for autoscaling"
  type        = number
}

variable "max_node" {
  description = "maximum no of nodes for autoscaling"
  type        = number
}

variable "service_account" {
  description = "service account name"
  type = string
}

#variable "bucket_name" {
#description = "google storage bucket name where the terrform state files will be located"
#type = string 
#}

#variable "auth_file" {
#description = "service account credential file for terraform to assume to provision the resources"
#type = string
#}
