terraform {

  cloud {
    organization = "HenriqueFM96"

    workspaces {
      name = " FortiLab-GCP-100"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5.0"
    }
  }

  required_version = ">= 1.1.0"
}