# Yandex Cloud Credentials
yc_cloud_id  = "ваш-cloud-id"
yc_folder_id = "ваш-folder-id"

# Способ 1: Аутентификация через файл ключа сервисного аккаунта
service_account_key_file = "/path/to/your/service-account-key.json"

# Способ 2: Аутентификация через токен (закомментировать, если используете файл)
# yc_token = "ваш-oauth-или-iam-токен"

# Zone Configuration
yc_zone = "ru-central1-a"

# SSH Configuration
vm_user = "ubuntu"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host"

# Environment
environment = "diploma"

# VM Configuration
vm_preemptible = true
web_server_count = 2

# Network Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
private_app_subnet_cidr = "10.0.2.0/24"
private_data_subnet_cidr = "10.0.3.0/24"