terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name        = "fortilab-gcp-100-vpc"
  description = "FortiLab VPC - GCP 100"
}

resource "google_compute_firewall" "default" {
  name        = "fortilab-firewall-rules"
  network     = "fortilab-gcp-100-vpc"
  description = "Creates firewall rule targeting tagged instances"
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags = ["jumpserver"]
}

resource "google_compute_firewall" "rdp-js" {
  name        = "fortilab-rdp-js"
  network     = "fortilab-gcp-100-vpc"
  description = "Creates firewall rule targeting tagged instances"
  allow {
    protocol = "tcp"
    ports    = ["443","3389"]
  }
}

resource "google_compute_instance" "vm_instance" {
  name         = "gcp100-js-fortilab"
  machine_type = "e2-standard-4"
  tags         = ["jumpserver"]
  zone = var.zone
  # Set a custom hostname below 
  hostname = "gcp100-js.fortilab.com"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2204-lts"
    }
  }
  
  metadata = {
    startup-script = <<-EOF
    sudo apt update -y
    
    echo 'script finished :)' > ~/test.txt
    EOF
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    #subnetwork = "fortilab-100-subnet-01"
    access_config {
    }
  }
}
