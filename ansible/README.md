# Ansible для дипломного проекта

Этот каталог содержит Ansible конфигурации для управления инфраструктурой дипломного проекта.

## Структура

- `inventory.ini` - инвентарь в формате INI (генерируется Terraform)
- `inventory.yml` - инвентарь в формате YAML (генерируется Terraform)
- `ansible.cfg` - конфигурация Ansible (генерируется Terraform)
- `test_playbook.yml` - простой тестовый playbook для проверки инфраструктуры
- `check_services.yml` - playbook для проверки установленных сервисов
- `system_info.yml` - playbook для сбора информации о системе
- `network_test.yml` - playbook для проверки сетевых соединений

## Генерация инвентаря

Инвентарь автоматически генерируется Terraform при выполнении `terraform apply` в каталоге `terraform/`.

Если нужно сгенерировать инвентарь без применения всей инфраструктуры:

```bash
cd terraform
terraform apply -target=local_file.ansible_inventory_ini -target=local_file.ansible_inventory_yaml -target=local_file.ansible_config
```

## Использование

### 1. Проверка подключения

```bash
# Проверка подключения ко всем хостам
ansible -i inventory.ini all -m ping

# Проверка подключения к конкретной группе
ansible -i inventory.ini web_servers -m ping
```

### 2. Запуск тестовых playbook

```bash
# Основной тестовый playbook
ansible-playbook -i inventory.ini test_playbook.yml

# Проверка установленных сервисов
ansible-playbook -i inventory.ini check_services.yml

# Сбор информации о системе
ansible-playbook -i inventory.ini system_info.yml

# Проверка сетевых соединений
ansible-playbook -i inventory.ini network_test.yml
```

### 3. Тестирование отдельных групп

```bash
# Только веб-сервера
ansible-playbook -i inventory.ini test_playbook.yml --limit web_servers

# Только сервер мониторинга
ansible-playbook -i inventory.ini test_playbook.yml --limit zabbix_server

# Только Elasticsearch и Kibana
ansible-playbook -i inventory.ini test_playbook.yml --limit elasticsearch,kibana
```

## Группы хостов

Инвентарь содержит следующие группы:

- `bastion` - бастион хост
- `web_servers` - веб-сервера (nginx)
- `zabbix_server` - сервер Zabbix
- `elasticsearch` - сервер Elasticsearch
- `kibana` - сервер Kibana
- `monitoring_agents` - все агенты мониторинга (веб-сервера)
- `log_collection` - сервера для сбора логов (веб-сервера)
- `all_servers` - все сервера

## Подключение через бастион

Для подключения к приватным хостам (веб-сервера, Elasticsearch) через бастион можно использовать один из двух подходов:

### Вариант 1: Запуск Ansible на бастионе
```bash
# Копируем файлы на бастион
scp -r ansible/ user@bastion_ip:/tmp/

# Подключаемся к бастиону и запускаем Ansible
ssh user@bastion_ip
cd /tmp/ansible
ansible-playbook -i inventory.ini test_playbook.yml --limit web_servers,elasticsearch
```

### Вариант 2: Запуск с локальной машины через ProxyCommand
Настройте `ansible.cfg` или используйте переменные окружения для ProxyCommand.

## Требования к сервисам

Согласно заданию, на серверах должны быть установлены:

### Веб-сервера
- nginx
- zabbix-agent
- filebeat

### Сервер Zabbix
- Zabbix server
- Zabbix frontend
- PostgreSQL (или внешняя БД)

### Elasticsearch
- Elasticsearch

### Kibana
- Kibana

Playbook `check_services.yml` проверяет наличие этих пакетов.

## Дополнительные команды

```bash
# Проверка версии Ansible
ansible --version

# Просмотр инвентаря
ansible-inventory -i inventory.ini --list

# Выполнение команды на всех хостах
ansible -i inventory.ini all -a "hostname"

# Проверка использования диска
ansible -i inventory.ini all -a "df -h"

# Проверка использования памяти
ansible -i inventory.ini all -a "free -m"
```

## Устранение неполадок

1. **Ошибка подключения**: Убедитесь, что SSH ключ добавлен в агент (`ssh-add ~/.ssh/id_ed25519`)
2. **Ошибка разрешения имен**: Убедитесь, что FQDN имена разрешаются в сети Yandex Cloud
3. **Ошибка прав доступа**: Убедитесь, что пользователь имеет права sudo на целевых хостах
4. **Ошибка инвентаря**: Проверьте, что файлы инвентаря сгенерированы Terraform