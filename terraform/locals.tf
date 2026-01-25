locals {
  project_name   = "diplom"
  project_prefix = "${var.environment}-${local.project_name}"
  
  # VM Specifications
  vm_specs = {
    web = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      disk_size     = 10
    }
    monitoring = {
      cores         = 2
      memory        = 4
      core_fraction = 20
      disk_size     = 20
    }
    bastion = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      disk_size     = 10
    }
  }
  
  # Common Tags
  common_tags = {
    Project     = local.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}