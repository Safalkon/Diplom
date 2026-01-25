terraform {
  required_version = ">= 1.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.120.0"
    }
  }
}

provider "yandex" {
  # Вариант 1: Аутентификация через файл ключа сервисного аккаунта (рекомендуется)
  service_account_key_file = var.service_account_key_file
  
  # Вариант 2: Аутентификация через токен (альтернатива)
  # token = var.yc_token
  
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}