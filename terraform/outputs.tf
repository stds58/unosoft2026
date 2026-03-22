output "internal_ip_address_a_server" {
  value = module.vm-a.internal_ip_address
}

output "internal_ip_address_b_server" {
  value = module.vm-b.internal_ip_address
}

output "external_ip_address_b_server" {
  value = module.vm-b.external_ip_address
}

output "connect_to_b_server" {
  value = "ssh -i ~/.ssh/key_to_bastion ubuntu@${module.vm-b.external_ip_address}"
}

output "connect_to_a_server" {
  value = format(
    "ssh -t -i %s/%s ubuntu@%s \"ssh -i ~/.ssh/%s ubuntu@%s\"",
    var.ssh_base_path,
    var.bastion_key_name,
    module.vm-b.external_ip_address,
    var.cluster_key_name,
    module.vm-a.internal_ip_address
  )
}
