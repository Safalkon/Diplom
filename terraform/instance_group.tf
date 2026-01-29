resource "yandex_compute_instance_group" "web_ig" {
  name               = "${local.project_prefix}-web-ig"
  service_account_id = var.service_account_id
  deletion_protection = false

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = local.vm_specs.web.cores
      memory        = local.vm_specs.web.memory
      core_fraction = local.vm_specs.web.core_fraction
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        size     = local.vm_specs.web.disk_size
        type     = "network-ssd"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.main.id
      subnet_ids = [for zone in ["ru-central1-a", "ru-central1-b"] : 
                   yandex_vpc_subnet.private_app[zone].id]
      security_group_ids = [yandex_vpc_security_group.web.id]
      nat                = false
    }

    metadata = {
      ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
      user-data = <<-EOF
apt-get update && apt-get install -y nginx
systemctl start nginx
EOF
    }

    labels = merge(local.common_tags, {
      role = "web-server"
    })
  }

  scale_policy {
    fixed_scale {
      size = var.web_server_count
    }
  }

  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
    startup_duration = 60
  }

  /* health_check {
    interval            = 5      # 2 секунды
    timeout             = 4      # 1 секунда
    unhealthy_threshold = 3      # 2 неудачи
    healthy_threshold   = 2      # 1 успех достаточно!
    
    # Проверяем просто доступность порта 80 (TCP)
    tcp_options {
      port = 80
    }
  }
  */

  load_balancer {
    target_group_name        = "${local.project_prefix}-web-target-group"
    target_group_description = "Target group for web instance group"
  }

  depends_on = [
    yandex_vpc_subnet.private_app,
    yandex_vpc_security_group.web
  ]

  labels = local.common_tags
}