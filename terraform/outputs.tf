output "all_internal_ips_a_server" {
  description = "Список всех внутренних IP-адресов Cassandra node"
  value       = module.vm-a.all_internal_ips
}

output "first_internal_ip_address_b_server" {
  description = "Первый внутренний ip бастиона"
  value = module.vm-b.internal_ip_address
}

output "external_ip_address_b_server" {
  description = "Первый внешний ip бастиона"
  value = module.vm-b.external_ip_address
}

output "connect_to_b_server" {
  description = "строка подключения к бастиону"
  value = "ssh -i ~/.ssh/key_to_bastion ubuntu@${module.vm-b.external_ip_address}"
}

output "connect_to_a_server" {
  description = "строка подключения к серверу с кассандрой через бастион"
  value = format(
    "ssh -t -i %s/%s ubuntu@%s \"ssh -i ~/.ssh/%s ubuntu@%s\"",
    var.ssh_base_path,
    var.bastion_key_name,
    module.vm-b.external_ip_address,
    var.cluster_key_name,
    module.vm-a.internal_ip_address
  )
}
