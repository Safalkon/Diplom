# Instance Group для веб-серверов (фиксированное количество)
resource "yandex_compute_instance_group" "web_ig" {
  name               = "${local.project_prefix}-web-ig"
  service_account_id = var.service_account_id
  deletion_protection = false

  instance_template {
    platform_id = "standard-v3"
    description = "Web server instance template"

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
        package_update: true
        package_upgrade: false
        packages:
          - nginx
          - python3
        runcmd:
          - mkdir -p /var/www/html
          - echo "Web Server Instance" > /var/www/html/index.html
          - systemctl enable nginx --now
          - echo "OK" > /var/www/html/index.html
      EOF
    }

    labels = merge(local.common_tags, {
      role = "web-server"
    })
  }

  # ФИКСИРОВАННОЕ количество инстансов (без автоскейлинга)
  scale_policy {
    fixed_scale {
      size = var.web_server_count
    }
  }

  # Распределение по зонам
  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  # Политика деплоя
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0  # Устанавливаем 0, так как автоскейлинг отключен
  }

  # Health check для Instance Group
  health_check {
    interval            = 10
    timeout             = 7
    unhealthy_threshold = 10
    healthy_threshold   = 6
    
    http_options {
      port = 80
      path = "/health"
    }
  }

  # Интеграция с Load Balancer
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