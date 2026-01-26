# VPC Network
resource "yandex_vpc_network" "main" {
  name        = "${local.project_prefix}-vpc"
  description = "Main VPC for diploma project"
  labels      = local.common_tags
}

# Public Subnet
resource "yandex_vpc_subnet" "public" {
  name           = "${local.project_prefix}-public-subnet"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
  zone           = var.yc_zone
  
  labels = merge(local.common_tags, {
    SubnetType = "public"
  })
}

# Private App Subnet
resource "yandex_vpc_subnet" "private_app" {
  name           = "${local.project_prefix}-private-app-subnet"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_app_subnet_cidr]
  zone           = var.yc_zone
  
  labels = merge(local.common_tags, {
    SubnetType = "private-app"
  })
}

# Private Data Subnet
resource "yandex_vpc_subnet" "private_data" {
  name           = "${local.project_prefix}-private-data-subnet"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_data_subnet_cidr]
  zone           = var.yc_zone
  
  labels = merge(local.common_tags, {
    SubnetType = "private-data"
  })
}

# NAT Gateway
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${local.project_prefix}-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route" {
  name       = "${local.project_prefix}-nat-route"
  network_id = yandex_vpc_network.main.id
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
  
  labels = local.common_tags
}

# Route table bindings for private subnets
resource "yandex_vpc_subnet_route_table_binding" "private_app" {
  subnet_id      = yandex_vpc_subnet.private_app.id
  route_table_id = yandex_vpc_route_table.nat_route.id
}

resource "yandex_vpc_subnet_route_table_binding" "private_data" {
  subnet_id      = yandex_vpc_subnet.private_data.id
  route_table_id = yandex_vpc_route_table.nat_route.id
}