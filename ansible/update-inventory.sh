#!/bin/bash
# Скрипт ручного обновления inventory

echo "🔄 Обновление inventory файла..."

# Переходим в директорию Terraform
cd ../terraform

# Получаем IP адреса
BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "NOT_FOUND")
ZABBIX_IP=$(terraform output -raw zabbix_public_ip 2>/dev/null || echo "NOT_FOUND")
KIBANA_IP=$(terraform output -raw kibana_public_ip 2>/dev/null || echo "NOT_FOUND")

# Получаем внутренние IP веб-серверов
WEB1_IP=$(terraform output -json web_servers 2>/dev/null | jq -r '.["diploma-web-1"].internal_ip' || echo "10.0.2.10")
WEB2_IP=$(terraform output -json web_servers 2>/dev/null | jq -r '.["diploma-web-2"].internal_ip' || echo "10.0.3.10")

# Создаем новый inventory файл
cat > ../ansible/inventory/hosts << EOF
# Автоматически обновлено $(date)

# Бастион хост
[bastion]
bastion ansible_host=$BASTION_IP

# Веб-сервера
[webservers]
web1 ansible_host=$WEB1_IP
web2 ansible_host=$WEB2_IP

# Zabbix сервер
[monitoring]
zabbix ansible_host=$ZABBIX_IP

# ELK сервера
[elasticsearch]
elasticsearch ansible_host=10.0.5.10

[kibana]
kibana ansible_host=$KIBANA_IP

# Группы
[all_hosts:children]
bastion
webservers
monitoring
elasticsearch
kibana

[internal_hosts:children]
webservers
elasticsearch

# Переменные
[bastion:vars]
is_bastion=true

[webservers:vars]
role=web-server

[monitoring:vars]
role=monitoring

[elasticsearch:vars]
role=elasticsearch

[kibana:vars]
role=kibana
EOF

echo "✅ Inventory обновлен!"
echo "📊 Актуальные IP:"
echo "   Bastion: $BASTION_IP"
echo "   Web1: $WEB1_IP"
echo "   Web2: $WEB2_IP"
echo "   Zabbix: $ZABBIX_IP"
echo "   Kibana: $KIBANA_IP"