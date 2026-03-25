locals {
  sg_bastion_egress_rules = [
    {
      protocol       = "tcp"
      port           = 22
      description    = "SSH to Internal Network"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "TCP"
      port           = 80
      description    = "HTTP outbound"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol       = "TCP"
      port           = 443
      description    = "HTTPS outbound"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol       = "UDP"
      port           = 53
      description    = "DNS outbound"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol       = "TCP"
      port           = 53
      description    = "DNS TCP outbound"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol       = "tcp"
      port           = 9042
      description    = "Cassandra CQL"
      v4_cidr_blocks = ["192.168.1.0/24"]
    }
  ]
}