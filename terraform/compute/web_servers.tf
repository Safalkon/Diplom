# Data source for Ubuntu image
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Web Servers with explicit zone assignment
resource "yandex_compute_instance" "web" {
  for_each = {
    "web1" = {
      zone   = "ru-central1-a"
      subnet = "ru-central1-a"
      ip_idx = 10
    }
    "web2" = {
      zone   = "ru-central1-b"
      subnet = "ru-central1-b"
      ip_idx = 11
    }
  }
  
  name        = "${local.project_prefix}-${each.key}"
  hostname    = "${local.project_prefix}-${each.key}.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = each.value.zone
  
  resources {
    cores         = local.vm_specs.web.cores
    memory        = local.vm_specs.web.memory
    core_fraction = local.vm_specs.web.core_fraction
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.vm_specs.web.disk_size
      type     = "network-ssd"
    }
  }
  
  network_interface {
    subnet_id          = yandex_vpc_subnet.private_app[each.value.subnet].id
    security_group_ids = [yandex_vpc_security_group.web.id]
    nat                = false
    ip_address         = cidrhost(yandex_vpc_subnet.private_app[each.value.subnet].v4_cidr_blocks[0], each.value.ip_idx)
  }
  
  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  
  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
    user-data =-EOF
      #cloud-config
      package_update: true
      packages:
        - nginx
        - python3
      runcmd:
        - mkdir -p /var/www/html
        - echo "Web Server ${each.key} in ${each.value.zone}" > /var/www/html/index.html
        - systemctl enable nginx
        - systemctl start nginx
      EOF
  }
  
  labels = merge(local.common_tags, {
    Role = "web-server"
    Zone = each.value.zone
  })
  
  depends_on = [
    yandex_vpc_subnet.private_app,
    yandex_vpc_security_group.web
  ]
}