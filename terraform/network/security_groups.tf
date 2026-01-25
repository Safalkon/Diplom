# Security Group for Bastion
resource "yandex_vpc_security_group" "bastion" {
  name        = "${local.project_prefix}-bastion-sg"
  description = "Security group for bastion host"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Component = "security-group"
    Role      = "bastion"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "SSH access from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Web Servers
resource "yandex_vpc_security_group" "web" {
  name        = "${local.project_prefix}-web-sg"
  description = "Security group for web servers"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Component = "security-group"
    Role      = "web"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "HTTP from anywhere (will be restricted to ALB)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Zabbix agent"
    v4_cidr_blocks = ["10.0.0.0/16"]  # From monitoring subnet
    port           = 10050
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Elasticsearch
resource "yandex_vpc_security_group" "elasticsearch" {
  name        = "${local.project_prefix}-elasticsearch-sg"
  description = "Security group for Elasticsearch"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Component = "security-group"
    Role      = "elasticsearch"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "Elasticsearch HTTP API"
    v4_cidr_blocks = ["10.0.0.0/16"]  # Allow from entire VPC
    port           = 9200
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Elasticsearch transport"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 9300
  }
  
  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Zabbix agent"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 10050
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Zabbix
resource "yandex_vpc_security_group" "zabbix" {
  name        = "${local.project_prefix}-zabbix-sg"
  description = "Security group for Zabbix server"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Component = "security-group"
    Role      = "zabbix"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "Zabbix web UI"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Zabbix web UI HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  
  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Zabbix server port"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 10051
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Kibana
resource "yandex_vpc_security_group" "kibana" {
  name        = "${local.project_prefix}-kibana-sg"
  description = "Security group for Kibana"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Component = "security-group"
    Role      = "kibana"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "Kibana web UI"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
  
  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Zabbix agent"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 10050
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# NAT Gateway Configuration
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

# Route Table Bindings
resource "yandex_vpc_subnet_route_table_binding" "private_app" {
  subnet_id      = yandex_vpc_subnet.private_app.id
  route_table_id = yandex_vpc_route_table.nat_route.id
}

resource "yandex_vpc_subnet_route_table_binding" "private_data" {
  subnet_id      = yandex_vpc_subnet.private_data.id
  route_table_id = yandex_vpc_route_table.nat_route.id
}