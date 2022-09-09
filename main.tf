/******************************************
	VPC configuration
 *****************************************/
module "vpc" {
  source                                 = "./modules/vpc"
  network_name                           = var.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  routing_mode                           = var.routing_mode
  project_id                             = var.project_id
  description                            = var.description
  shared_vpc_host                        = var.shared_vpc_host
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  mtu                                    = var.mtu
}

/******************************************
	Subnet configuration
 *****************************************/
module "subnets" {
  source           = "./modules/subnets"
  project_id       = var.project_id
  network_name     = module.vpc.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}

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

/*
module "vpc" {
    source  = "terraform-google-modules/network/google"
    #version = "~> 4.0"

  project_id = var.project
  network_name = "fortilab-gcp-100-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name = "fortilab-100-subnet-01"
      subnet_ip = "10.10.10.0/24"
      subnet_region = var.region
      description = "public subnet"
    },
    {
      subnet_name = "fortilab-100-subnet-02"
      subnet_ip = "10.10.20.0/24"
      subnet_region = var.region
      subnet_private_access = "true"
      description = "private subnet"
    }
  ]
}
*/

resource "google_compute_firewall" "default" {
  name        = "fortilab-firewall-rules"
  network     = "fortilab-gcp-100-vpc"
  description = "Creates firewall rule targeting tagged instances"
  source_ranges = "35.235.240.0/20"
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  target_tags = ["jumpserver"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "gcp100-js-fortilab"
  machine_type = "f1-micro"
  tags         = ["jumpserver"]
  zone = var.zone
  # Set a custom hostname below 
  hostname = "gcp100-js.fortilab.com"
  network_ip	= "10.10.10.10/24"
  subnetwork = "fortilab-100-subnet-01"

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
