provider "google" {
  project = "${var.project_id}"
  region = "${var.region}"
  credentials = file("~/secret/e257dc29b1460-ckad-gcp-terraform-simple-gke.json")
}

variable "project_id" {
}

variable "region" {
}

variable "cluster_name" {
}

variable "pool_name" {
}

variable "node_count" {
}

resource "google_container_cluster" "primary" {
  name     = "${var.cluster_name}"
  location = "${var.region}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
#  enable_kubernetes_alpha = true

  release_channel {
    channel = "RAPID"
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.pool_name}"
  location   = "${var.region}"
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  
#  management {
#    auto_repair = false
#    auto_upgrade= false
#  }
}
