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
  region  = var.region
}

resource "google_compute_instance" "custom_hostname_instance" {
  name         = "custom-hostname-instance-name"
  machine_type = "f1-micro"
  zone = var.zone

  # Set a custom hostname below 
  hostname = "gcp100.fortilab.com"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}
