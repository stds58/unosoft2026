locals {
  bastion_ip_suffixes = var.bastion_ip_suffixes

  bastion_interfaces = [
    for suffix in local.bastion_ip_suffixes : {
      subnet_id          = module.subnetwork.subnet_id
      ip_address         = "192.168.1.${suffix}"
      nat                = true
      security_group_ids = [module.sg_bastion.security_group_id]
    }
  ]
}
