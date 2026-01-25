# Public Subnet (DMZ)
resource "yandex_vpc_subnet" "public" {
  name           = "${local.project_prefix}-public-subnet"
  description    = "Public subnet for bastion, ALB, and monitoring"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
  zone           = var.yc_zone
  
  labels = merge(local.common_tags, {
    SubnetType = "public"
    Purpose    = "dmz"
  })
}

# Private App Subnet (Web Servers)
resource "yandex_vpc_subnet" "private_app" {
  name           = "${local.project_prefix}-private-app-subnet"
  description    = "Private subnet for web application servers"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_app_subnet_cidr]
  zone           = var.yc_zone
  
  labels = merge(local.common_tags, {
    SubnetType = "private"
    Purpose    = "application"
  })
}

# Private Data Subnet (Elasticsearch)
resource "yandex_vpc_subnet" "private_data" {
  name           = "${local.project_prefix}-private-data-subnet"
  description    = "Private subnet for data services (Elasticsearch)"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_data_subnet_cidr]
  zone           = var.yc_zone
  
  labels = merge(local.common_tags, {
    SubnetType = "private"
    Purpose    = "data"
  })
}