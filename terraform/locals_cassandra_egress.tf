locals {
  sg_cassandra_egress_rules = [
    {
      protocol       = "TCP"
      port           = 3128
      description    = "Allow HTTP Proxy to Bastion"
      v4_cidr_blocks = ["192.168.1.198/32"]
    },
    {
      protocol       = "TCP"
      port           = 7000
      description    = "Allow internal cluster communication"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "TCP"
      port           = 7001
      description    = "Allow internal cluster communication"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "TCP"
      port           = 7199
      description    = "Allow internal cluster communication"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "TCP"
      port           = 9042
      description    = "Allow internal cluster communication"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "UDP"
      port           = 53
      description    = "DNS to Yandex Internal Resolver"
      v4_cidr_blocks = ["169.254.169.253/32"]
    },
    {
      protocol       = "TCP"
      port           = 53
      description    = "DNS TCP to Yandex Internal Resolver"
      v4_cidr_blocks = ["169.254.169.253/32"]
    },
    {
      protocol       = "TCP"
      port           = -1
      description    = "SSH responses to Bastion (ephemeral ports)"
      v4_cidr_blocks = ["192.168.1.0/24"]
    }
  ]
}