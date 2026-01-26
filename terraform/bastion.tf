# Bastion Host
resource "yandex_compute_instance" "bastion" {
  name        = "${local.project_prefix}-bastion"
  hostname    = "${local.project_prefix}-bastion.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = var.yc_zone
  
  resources {
    cores         = local.vm_specs.bastion.cores
    memory        = local.vm_specs.bastion.memory
    core_fraction = local.vm_specs.bastion.core_fraction
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.vm_specs.bastion.disk_size
      type     = "network-ssd"
    }
  }
  
  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.bastion.id]
    nat                = true
  }
    depends_on = [
    yandex_vpc_subnet.public,
    yandex_vpc_security_group.bastion
  ]

  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  
  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      package_upgrade: true
      packages:
        - fail2ban
        - python3
        - python3-pip
        - ansible
      runcmd:
        - systemctl enable fail2ban
        - systemctl start fail2ban
        - sed -i 's/^#Port 22/Port 6022/' /etc/ssh/sshd_config
        - systemctl restart sshd
      EOF
  }
  
  labels = merge(local.common_tags, {
    Role = "bastion"
  })
}