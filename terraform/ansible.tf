resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    instances = [
      {
        name        = module.vm-a.vm_name
        role        = lookup(module.vm-a.vm_labels, "role", "unknown")
        internal_ip = module.vm-a.internal_ip_address
        external_ip = ""
      },
      {
        name        = module.vm-b.vm_name
        role        = lookup(module.vm-b.vm_labels, "role", "unknown")
        internal_ip = module.vm-b.internal_ip_address
        external_ip = module.vm-b.external_ip_address
      }
    ]
    bastion_external_ip = module.vm-b.external_ip_address
    bastion_key_path    = format("/home/valar/.ssh/%s", var.bastion_key_name)
    cluster_key_path    = format("/home/valar/.ssh/%s", var.cluster_key_name)
  })

  filename = "${path.root}/../ansible/inventory.ini"
}