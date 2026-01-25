# VPC Network
resource "yandex_vpc_network" "main" {
  name        = "${local.project_prefix}-vpc"
  description = "Main VPC for diploma project"
  labels      = local.common_tags
}

# Public Subnet (только в одной зоне для bastion и ALB)
resource "yandex_vpc_subnet" "public" {
  name           = "${local.project_prefix}-public-subnet"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
  zone           = var.yc_zone  # Используем основную зону
  
  labels = merge(local.common_tags, {
    SubnetType = "public"
  })
}

# Private App Subnets в разных зонах
resource "yandex_vpc_subnet" "private_app" {
  for_each = var.private_app_subnet_cidrs
  
  name           = "${local.project_prefix}-private-app-${each.key}"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value]
  zone           = each.key
  
  labels = merge(local.common_tags, {
    SubnetType = "private-app"
    Zone       = each.key
  })
}

# Private Data Subnet (Elasticsearch) в отдельной зоне
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

# Route table bindings для ВСЕХ приватных подсетей
resource "yandex_vpc_subnet_route_table_binding" "private_app" {
  for_each = yandex_vpc_subnet.private_app
  
  subnet_id      = each.value.id
  route_table_id = yandex_vpc_route_table.nat_route.id
}

resource "yandex_vpc_subnet_route_table_binding" "private_data" {
  subnet_id      = yandex_vpc_subnet.private_data.id
  route_table_id = yandex_vpc_route_table.nat_route.id
}