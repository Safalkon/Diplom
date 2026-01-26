terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
# Target Group
resource "yandex_alb_target_group" "web" {
  name = "${local.project_prefix}-target-group"
  
  dynamic "target" {
    for_each = yandex_compute_instance.web
    
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
  
  labels = local.common_tags
}

# Backend Group с health check
resource "yandex_alb_backend_group" "web" {
  name = "${local.project_prefix}-backend-group"
  
  http_backend {
    name             = "http-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]
    
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 5
      unhealthy_threshold = 3
      
      http_healthcheck {
        path = "/"
      }
    }
  }
  
  labels = local.common_tags
}

# HTTP Router
resource "yandex_alb_http_router" "web" {
  name = "${local.project_prefix}-http-router"
  
  labels = local.common_tags
}

# Virtual Host
resource "yandex_alb_virtual_host" "web" {
  name           = "default-host"
  http_router_id = yandex_alb_http_router.web.id
  
  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "60s"
      }
    }
  }
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "web" {
  name               = "${local.project_prefix}-alb"
  network_id         = yandex_vpc_network.main.id
  
  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.public.id
    }
  }
  
  listener {
    name = "http-listener"
    
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
  
  labels = local.common_tags
  
  depends_on = [
    yandex_vpc_subnet.public,
    yandex_alb_target_group.web
  ]
}