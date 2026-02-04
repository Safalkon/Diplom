# Ansible Configuration for Diplom Infrastructure

This directory contains Ansible playbooks and roles for configuring the infrastructure deployed via Terraform.

## Overview

The infrastructure includes:
- Bastion host (jump server)
- Web servers (nginx) in instance group across two zones
- Zabbix monitoring server
- Elasticsearch for log storage
- Kibana for log visualization
- Filebeat agents on web servers for log shipping

## Prerequisites

1. Terraform infrastructure must be deployed and outputs available.
2. Ansible 2.9+ installed on control machine (or bastion host).
3. SSH access to bastion host and internal hosts via bastion.

## Inventory

The inventory is defined in `inventory.yml` using FQDN names (`.ru-central1.internal`). It includes groups:

- `bastion`: bastion host with public IP
- `web`: web servers in private subnet
- `zabbix_server`: Zabbix server with public IP
- `elasticsearch`: Elasticsearch in private subnet
- `kibana`: Kibana with public IP
- `zabbix_agents`: all hosts that need Zabbix agent

### Dynamic Inventory

You can generate inventory from Terraform outputs using the script `scripts/generate_inventory.py`. First, ensure you have terraform outputs in JSON format:

```bash
cd terraform
terraform output -json > output.json
```

Then run the script:

```bash
cd ansible
python3 scripts/generate_inventory.py > inventory.yml
```

The script will create an inventory with all hosts and groups based on Terraform outputs.

## Variables

Global variables are in `group_vars/all.yml`. Override per group in `group_vars/<group>.yml` or per host in `host_vars/`.

Important variables:
- `zabbix_server_ip`: IP of Zabbix server for agents
- `elasticsearch_host`: hostname for Elasticsearch
- `environment`: deployment environment tag

## Roles

- `common`: basic system setup (packages, timezone)
- `bastion`: SSH hardening, fail2ban
- `web`: nginx installation, static site deployment
- `zabbix_agent`: Zabbix agent 2 configuration
- `zabbix_server`: Zabbix server with PostgreSQL
- `elasticsearch`: Elasticsearch 8.x setup
- `kibana`: Kibana 8.x setup
- `filebeat`: Filebeat configuration for nginx logs
- `backup`: backup scripts for configuration files

## Playbooks

- `site.yml`: main playbook applying all roles
- `zabbix_setup.yml`: optional playbook for adding hosts to Zabbix via API
- `elk_status.yml`: verify Elasticsearch and Kibana connectivity

## Usage

### 1. Prepare SSH configuration

Ensure your SSH key is added to the bastion host and internal hosts (via Terraform metadata).

### 2. Update inventory

If using static inventory, update hostnames and internal IPs based on Terraform outputs:

```bash
cd terraform
terraform output -json fqdn_list > ../ansible/inventory.json
python3 ../ansible/scripts/generate_inventory.py
```

### 3. Run Ansible

From the ansible directory:

```bash
# Apply all configurations
ansible-playbook -i inventory.yml site.yml

# Apply only to web servers
ansible-playbook -i inventory.yml site.yml --limit web

# Check connectivity
ansible all -i inventory.yml -m ping
```

### 4. Access services

- Web: http://ALB_PUBLIC_IP (from Terraform output `alb_public_ip`)
- Zabbix: http://ZABBIX_PUBLIC_IP (output `zabbix_public_ip`)
- Kibana: http://KIBANA_PUBLIC_IP (output `kibana_public_ip`)

## Security Notes

- Passwords in `group_vars/all.yml` are examples; replace with secure values.
- Use Ansible Vault for sensitive data.
- Security groups are managed by Terraform; ensure proper ingress/egress rules.

## Monitoring and Logging

- Zabbix agents report metrics to Zabbix server.
- Filebeat ships nginx logs to Elasticsearch.
- Kibana dashboards available at `http://kibana:5601`.

## Backup

- Snapshot schedules for VM disks are managed by Terraform (`snapshots.tf`).
- Configuration backup script runs daily via systemd timer (role `backup`).

## Troubleshooting

- Check Ansible verbose output with `-v`, `-vv`, `-vvv`.
- Verify SSH connectivity through bastion manually.
- Check service logs on respective hosts.

## License

This configuration is part of the Diplom project.