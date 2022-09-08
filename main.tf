terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  #credentials = file(terraform.workspace)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name        = "fortilab-gcp-100-vpc"
  description = "FortiLab VPC - GCP 100"
}

resource "google_compute_firewall" "default" {
  name    = "fortilab-firewall-rules"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_tags = ["application"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "gcp100-js-fortilab"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]
  zone = var.zone
  # Set a custom hostname below 
  hostname = "gcp100.fortilab.com"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}
