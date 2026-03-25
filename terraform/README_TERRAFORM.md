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
