# Security Group for Bastion
resource "yandex_vpc_security_group" "bastion" {
  name        = "${local.project_prefix}-bastion-sg"
  description = "Security group for bastion host"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Role = "bastion"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "SSH from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Web Servers
resource "yandex_vpc_security_group" "web" {
  name        = "${local.project_prefix}-web-sg"
  description = "Security group for web servers"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Role = "web"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "HTTP from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Zabbix
resource "yandex_vpc_security_group" "zabbix" {
  name        = "${local.project_prefix}-zabbix-sg"
  description = "Security group for Zabbix server"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Role = "zabbix"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "HTTP from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Elasticsearch
resource "yandex_vpc_security_group" "elasticsearch" {
  name        = "${local.project_prefix}-elasticsearch-sg"
  description = "Security group for Elasticsearch"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Role = "elasticsearch"
  })
  
  ingress {
    protocol       = "TCP"
    description    = "Elasticsearch HTTP"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 9200
  }
  
  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Kibana
resource "yandex_vpc_security_group" "kibana" {
  name        = "${local.project_prefix}-kibana-sg"
  description = "Security group for Kibana"
  network_id  = yandex_vpc_network.main.id
  
  labels = merge(local.common_tags, {
    Role = "kibana"
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
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}