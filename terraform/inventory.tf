
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.yml.tftpl", {
    bastion_fqdn              = yandex_compute_instance.bastion.fqdn
    bastion_public_ip         = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
    zabbix_fqdn               = yandex_compute_instance.zabbix.fqdn
    zabbix_public_ip          = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
    kibana_fqdn               = yandex_compute_instance.kibana.fqdn
    kibana_public_ip          = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
    elasticsearch_fqdn        = yandex_compute_instance.elasticsearch.fqdn
    elasticsearch_internal_ip = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
    web_instances             = yandex_compute_instance_group.web_ig.instances
  })
  filename = "${path.module}/../ansible/inventory.yml"
}
