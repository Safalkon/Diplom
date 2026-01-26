terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts-oslogin"
}