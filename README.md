# Cassandra Cluster Deployment

> Развертывание трёхнодового кластера Apache Cassandra в Docker с доступом к каждой ноде по отдельному IP-адресу из локальной сети

> Задание
> 
>   На машине А (ubuntu 24.04 lts) в локальной сети с ip 192.168.1.197 
>   запускается скрипт docker-compose для поднятия 3 образов с ip адресами 192.168.1.200-202.
>
>   Затем с машины Б (ubuntu 24.04 lts) из той же локальной сети с ip 192.168.1.198 
>   необходимо подключиться через cqlsh к каждой из машин-образов.
>
>   Настроить ssh для возможности подключения к 1.200 с 1.197
>   Все приведённые операции необходимо задокументировать и описать инструкцией с командами и объяснениями в Readme
>   Добавить скриншот результата в Readme.

## 🛠️ Инструменты разработки

![Terraform](https://img.shields.io/badge/-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white  )
![Ansible](https://img.shields.io/badge/-Ansible-E60000?style=for-the-badge&logo=ansible&logoColor=white  )
![Docker](https://img.shields.io/badge/-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white  )
![Cassandra](https://img.shields.io/badge/-Cassandra-1287B1?style=for-the-badge&logo=apache&logoColor=white  )
![Ubuntu](https://img.shields.io/badge/-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white  )
![YandexCloud](https://img.shields.io/badge/-YandexCloud-5282FF?style=for-the-badge&logo=yandex&logoColor=white  )

---

## 📋 Содержание

- [Описание](#-описание)
- [Архитектура](#-архитектура)
- [Требования](#-требования)
- [Быстрый старт](#-быстрый-старт)
- [Проверка кластера](#-проверка-кластера)
- [Структура проекта](#-структура-проекта)
- [Удаление ресурсов](#-удаление ресурсов)
- [Скриншоты](#-скриншоты)
- [Лицензия](#-лицензия)

---

## 📝 Описание

Проект разворачивает кластер **Apache Cassandra 4.1** из трёх нод в Docker-контейнерах на виртуальной машине в Yandex Cloud. Каждая нода доступна по отдельному статическому IP-адресу из локальной сети `192.168.1.0/24`.

### Ключевые особенности

| Функция | Описание |
|---------|----------|
| 🔹 Отдельные IP | Каждая нода доступна по IP `192.168.1.200`, `.201`, `.202` |
| 🔹 DNAT маршрутизация | Трафик перенаправляется на контейнеры через iptables |
| 🔹 Изоляция сети | Нет NAT на VM-A, весь трафик через бастион |
| 🔹 Proxy-доступ | TinyProxy на бастионе для выхода в интернет |
| 🔹 Автоматизация | Terraform + Ansible для полного цикла развёртывания |

---

## 🏗️ Архитектура

### Компоненты

| Компонент | Назначение | IP-адрес |
|-----------|------------|----------|
| **VM-A** | Хост для Cassandra нод | 192.168.1.197 |
| **VM-B (Bastion)** | Шлюз для доступа извне | 192.168.1.198 |
| **Node 1** | Cassandra нода #1 | 192.168.1.200 |
| **Node 2** | Cassandra нода #2 | 192.168.1.201 |
| **Node 3** | Cassandra нода #3 | 192.168.1.202 |
| **TinyProxy** | HTTP/HTTPS прокси на бастионе | 192.168.1.198:3128 |

### Terraform 

<details>
  <summary><strong>Terraform </strong></summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.5 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.7 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | ~> 0.193 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.7.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.193.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_sg_bastion"></a> [sg\_bastion](#module\_sg\_bastion) | ./modules/security-groups | n/a |
| <a name="module_sg_cassandra_cluster"></a> [sg\_cassandra\_cluster](#module\_sg\_cassandra\_cluster) | ./modules/security-groups | n/a |
| <a name="module_subnetwork"></a> [subnetwork](#module\_subnetwork) | ./modules/subnet | n/a |
| <a name="module_vm-a"></a> [vm-a](#module\_vm-a) | ./modules/instance | n/a |
| <a name="module_vm-b"></a> [vm-b](#module\_vm-b) | ./modules/instance | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ip_suffixes"></a> [bastion\_ip\_suffixes](#input\_bastion\_ip\_suffixes) | Список суффиксов IP-адресов для узлов бастионa | `list(number)` | <pre>[<br/>  198<br/>]</pre> | no |
| <a name="input_bastion_key_name"></a> [bastion\_key\_name](#input\_bastion\_key\_name) | Имя файла ключа для доступа к бастину (без расширения) | `string` | `"key_to_bastion"` | no |
| <a name="input_cassandra_ip_suffixes"></a> [cassandra\_ip\_suffixes](#input\_cassandra\_ip\_suffixes) | Список суффиксов IP-адресов для узлов Cassandra | `list(number)` | <pre>[<br/>  197<br/>]</pre> | no |
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | n/a | `string` | `""` | no |
| <a name="input_cluster_key_name"></a> [cluster\_key\_name](#input\_cluster\_key\_name) | Имя файла ключа для доступа от бастина к кластеру | `string` | `"bastion_to_cluster_key"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | ID каталога в Yandex Cloud | `string` | `""` | no |
| <a name="input_ssh_base_path"></a> [ssh\_base\_path](#input\_ssh\_base\_path) | Базовая директория для SSH-ключей | `string` | `"C:/Users/valar/.ssh"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Use specific availability zone | `string` | `"ru-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_internal_ips_a_server"></a> [all\_internal\_ips\_a\_server](#output\_all\_internal\_ips\_a\_server) | Список всех внутренних IP-адресов Cassandra node |
| <a name="output_connect_to_a_server"></a> [connect\_to\_a\_server](#output\_connect\_to\_a\_server) | строка подключения к серверу с кассандрой через бастион |
| <a name="output_connect_to_b_server"></a> [connect\_to\_b\_server](#output\_connect\_to\_b\_server) | строка подключения к бастиону |
| <a name="output_external_ip_address_b_server"></a> [external\_ip\_address\_b\_server](#output\_external\_ip\_address\_b\_server) | Первый внешний ip бастиона |
| <a name="output_first_internal_ip_address_b_server"></a> [first\_internal\_ip\_address\_b\_server](#output\_first\_internal\_ip\_address\_b\_server) | Первый внутренний ip бастиона |

## Resources

| Name | Type |
|------|------|
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.copy_private_key_to_vm1](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [yandex_compute_image.ubuntu](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/compute_image) | data source |
<!-- END_TF_DOCS -->

</details>

---

## ⚙️ Требования

| Инструмент | Версия | Примечание |
|------------|--------|------------|
| Terraform | >= 1.10.5 | Для инфраструктуры |
| Ansible | >= 2.14 | Для конфигурации |
| Docker | >= 24.0 | На хост-машине |
| WSL 2 | - | Для Windows-пользователей |

### Необходимые аккаунты и ключи

1. **Yandex Cloud аккаунт** с правами на создание:
   - VPC Network / Subnet
   - Compute VM
   - Security Groups
   - Object Storage (для бэкенда Terraform)

2. **Service Account Key** (`authorized_key.json`)

3. **SSH ключи**:

```bash
# Ключ для доступа к бастиону
ssh-keygen -t ed25519 -f ~/.ssh/key_to_bastion -N ""

# Ключ для доступа от бастиона к кластеру
ssh-keygen -t ed25519 -f ~/.ssh/bastion_to_cluster_key -N ""
```

---

## 🚀 Быстрый старт

### 1. Подготовка в Yandex Cloud

Создайте сервисный аккаунт и получите `authorized_key.json`. Поместите его в папку `terraform/`

### 2. Настройка Terraform

#### Создайте `backend-config.tfvars`:

```hcl
bucket     = "your-bucket-name"
key        = "terraform.tfstate"
region     = "ru-central1"
access_key = "your-access-key"
secret_key = "your-secret-key"
```

#### Создайте `terraform.tfvars`:

```hcl
cloud_id              = "your-cloud-id"
folder_id             = "your-folder-id"
ssh_base_path         = "C:/Users/<username>/.ssh"
bastion_key_name      = "key_to_bastion"
cluster_key_name      = "bastion_to_cluster_key"
cassandra_ip_suffixes = [197, 200, 201, 202]
bastion_ip_suffixes   = [198]
```

### 3. Развертывание инфраструктуры

```bash
cd terraform

terraform init -backend-config=backend-config.tfvars
terraform validate
terraform plan
terraform apply -auto-approve
```

После выполнения вы увидите:

```
Outputs:

all_internal_ips_a_server = [
  "192.168.1.197",
  "192.168.1.200",
  "192.168.1.201",
  "192.168.1.202",
]
connect_to_a_server = "ssh -t -i C:/Users/<user>/.ssh/<bastion_key> ubuntu@xxx.xxx.xxx.xxx \"ssh -i ~/.ssh/<cluster_key> ubuntu@192.168.1.197\""
connect_to_b_server = "ssh -i ~/.ssh/<bastion_key> ubuntu@xxx.xxx.xxx.xxx"
external_ip_address_b_server = "xxx.xxx.xxx.xxx"
first_internal_ip_address_b_server = "192.168.1.198"
```

terraform сам создаст inventory.ini для ansible

### 4. Запуск Ansible

```bash
cd ansible

wsl ansible-playbook -i inventory.ini playbook.yml
```

---

## 🔍 Проверка кластера

### Подключение к Cassandra с бастиона

```bash
# Подключение к ноде 1
cqlsh 192.168.1.200 9042
cqlsh 192.168.1.200 9042 -e "SELECT rpc_address, host_id, data_center, rack FROM system.local;"
# Подключение к ноде 2
cqlsh 192.168.1.201 9042
cqlsh 192.168.1.201 9042 -e "SELECT rpc_address, host_id, data_center, rack FROM system.local;"
# Подключение к ноде 3
cqlsh 192.168.1.202 9042
cqlsh 192.168.1.202 9042 -e "SELECT rpc_address, host_id, data_center, rack FROM system.local;"
```

### Проверка статуса кластера

```sql
-- На любой ноде выполните:
DESCRIBE CLUSTER;
```

---

## 📁 Структура проекта
<details>
  <summary><strong>Структура проекта</strong></summary>

```
unosoft2026/
├── ansible
│   ├── docs
│   │   ├── README.md
│   │   ├── roles.txt
│   │   ├── ключ.txt
│   │   ├── ограничения.txt
│   │   └── решение_заботы.txt
│   ├── group_vars
│   │   └── all.yml
│   ├── roles
│   │   ├── cassandra-client
│   │   │   ├── defaults
│   │   │   │   └── main.yml
│   │   │   ├── files
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── meta
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   ├── tests
│   │   │   │   ├── inventory
│   │   │   │   └── test.yml
│   │   │   ├── vars
│   │   │   │   └── main.yml
│   │   │   └── README.md
│   │   ├── cassandra-cluster
│   │   │   ├── defaults
│   │   │   │   └── main.yml
│   │   │   ├── files
│   │   │   │   ├── Dockerfile
│   │   │   │   ├── entrypoint.sh
│   │   │   │   └── sshd_config
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── meta
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   │   ├── .env.j2
│   │   │   │   ├── docker-compose.yml.j2
│   │   │   │   └── docker-compose2.yml.j2
│   │   │   ├── tests
│   │   │   │   ├── inventory
│   │   │   │   └── test.yml
│   │   │   ├── vars
│   │   │   │   └── main.yml
│   │   │   └── README.md
│   │   ├── docker
│   │   │   ├── defaults
│   │   │   │   └── main.yml
│   │   │   ├── files
│   │   │   │   └── docker.gpg
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── meta
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   ├── tests
│   │   │   │   ├── inventory
│   │   │   │   └── test.yml
│   │   │   ├── vars
│   │   │   │   └── main.yml
│   │   │   └── README.md
│   │   └── tinyproxy
│   │       ├── defaults
│   │       │   └── main.yml
│   │       ├── files
│   │       ├── handlers
│   │       │   └── main.yml
│   │       ├── meta
│   │       │   └── main.yml
│   │       ├── tasks
│   │       │   └── main.yml
│   │       ├── templates
│   │       ├── tests
│   │       │   ├── inventory
│   │       │   └── test.yml
│   │       ├── vars
│   │       │   └── main.yml
│   │       └── README.md
│   ├── ansible.cfg
│   └── playbook.yml
├── terraform
│   ├── modules
│   │   ├── instance
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── provider.tf
│   │   │   └── variables.tf
│   │   ├── network
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── provider.tf
│   │   │   └── variables.tf
│   │   ├── security-groups
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── provider.tf
│   │   │   └── variables.tf
│   │   └── subnet
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── provider.tf
│   │       └── variables.tf
│   ├── .terraform.lock.hcl
│   ├── ansible.tf
│   ├── authorized_key.json (добавить)
│   ├── backend-config.tfvars (добавить)
│   ├── backend.tf
│   ├── inventory.tpl
│   ├── locals_bastion_egress.tf
│   ├── locals_bastion_ingress.tf
│   ├── locals_bastion_interfaces.tf
│   ├── locals_cassandra_egress.tf
│   ├── locals_cassandra_inress.tf
│   ├── locals_cassandra_interfaces.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars (добавить)
│   └── variables.tf
├── .dockerignore
├── .gitattributes
├── .gitignore
├── img.png
├── img_1.png
├── img_2.png
├── LICENSE
├── README.md
└── tree.py
```
</details>

---

## 🗑️ Удаление ресурсов

```bash
cd terraform
terraform destroy -auto-approve
```

---

## 📸 Скриншоты

### Подключение к Cassandra с бастиона

<img src="img.png" alt="Подключение к Cassandra" width="800">

<img src="img_1.png" alt="Ноды кластера" width="800">

### VM-A хост. проверка нод кластера

<img src="img_2.png" alt="VM-A" width="800">

---

## 📄 Лицензия

Этот проект распространяется под лицензией [MIT](LICENSE).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

**Автор**: [Савостиков Валерий]  
**Дата**: 2026
