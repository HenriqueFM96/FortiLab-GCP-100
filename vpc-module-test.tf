module "vpc" {
    source  = "terraform-google-modules/network/google"
    #version = "~> 4.0"

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