# main.tf - корневой файл, включающий все ресурсы

# Провайдер (если его нет в providers.tf)

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
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

# Включение всех модулей
module "compute" {
  source = "./compute"
  providers = {
    yandex = yandex
  }
}

module "network" {
  source = "./network"
  providers = {
    yandex = yandex
  }
}

module "loadbalancer" {
  source = "./loadbalancer"
  providers = {
    yandex = yandex
  }
}

module "data" {
  source = "./data"
  providers = {
    yandex = yandex
  }
}