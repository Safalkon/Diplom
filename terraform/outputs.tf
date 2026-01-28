# Network Outputs
output "bastion_public_ip" {
  description = "Public IP address of bastion host"
  value       = try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, null)
}

output "alb_public_ip" {
  description = "Public IP address of Application Load Balancer"
  value       = try(yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address, null)
}

output "zabbix_public_ip" {
  description = "Public IP address of Zabbix server"
  value       = try(yandex_compute_instance.zabbix.network_interface[0].nat_ip_address, null)
}

output "kibana_public_ip" {
  description = "Public IP address of Kibana"
  value       = try(yandex_compute_instance.kibana.network_interface[0].nat_ip_address, null)
}

output "web_servers" {
  description = "Internal IP addresses and FQDNs of web servers"
  value = {
    for name, vm in yandex_compute_instance.web :
    name => {
      internal_ip = vm.network_interface[0].ip_address
      fqdn        = vm.hostname
      zone        = vm.zone
      subnet      = vm.network_interface[0].subnet_id
    }
  }
}

output "web_server_distribution" {
  description = "Web server distribution across zones"
  value = {
    for zone in local.web_server_zones :
    zone => [
      for name, vm in yandex_compute_instance.web :
      name if vm.zone == zone
    ]
  }
}

output "elasticsearch_internal_ip" {
  description = "Internal IP address of Elasticsearch"
  value       = try(yandex_compute_instance.elasticsearch.network_interface[0].ip_address, null)
}

output "fqdn_list" {
  description = "All FQDN names for Ansible inventory"
  value = {
    bastion       = try(yandex_compute_instance.bastion.hostname, null)
    web_servers   = try([for vm in yandex_compute_instance.web : vm.hostname], [])
    zabbix        = try(yandex_compute_instance.zabbix.hostname, null)
    elasticsearch = try(yandex_compute_instance.elasticsearch.hostname, null)
    kibana        = try(yandex_compute_instance.kibana.hostname, null)
  }
}

output "ssh_via_bastion" {
  description = "SSH command template to connect via bastion"
  value       = "ssh -J ${var.vm_user}@${try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, "BASTION_IP")} ${var.vm_user}@<internal_ip>"
}

output "vpc_info" {
  description = "VPC and subnet information"
  value = {
    vpc_id = try(yandex_vpc_network.main.id, null)
    subnets = {
      # Для подсетей с for_each нужно обращаться по ключам или собирать все
      public = try(
        { for k, v in yandex_vpc_subnet.public : k => {
          id          = v.id
          cidr_blocks = v.v4_cidr_blocks
          zone        = v.zone
        }},
        null
      )
      
      private_app = try(
        { for k, v in yandex_vpc_subnet.private_app : k => {
          id          = v.id
          cidr_blocks = v.v4_cidr_blocks
          zone        = v.zone
        }},
        null
      )
      
      private_data = try(
        { for k, v in yandex_vpc_subnet.private_data : k => {
          id          = v.id
          cidr_blocks = v.v4_cidr_blocks
          zone        = v.zone
        }},
        null
      )
    }
  }
}