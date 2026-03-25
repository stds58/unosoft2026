locals {
  cassandra_ip_suffixes = var.cassandra_ip_suffixes

  cassandra_interfaces = [
    for suffix in local.cassandra_ip_suffixes : {
      subnet_id          = module.subnetwork.subnet_id
      ip_address         = "192.168.1.${suffix}"
      nat                = false
      security_group_ids = [module.sg_cassandra_cluster.security_group_id]
    }
  ]
}