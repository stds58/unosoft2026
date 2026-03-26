locals {
  sg_cassandra_ingress_rules = [
    {
      protocol       = "tcp"
      port           = 22
      description    = "SSH from Bastion"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "tcp"
      port           = 2200
      description    = "SSH from Bastion to Cassandra CQL"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "tcp"
      port           = 2201
      description    = "SSH from Bastion to Cassandra CQL"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "tcp"
      port           = 2202
      description    = "SSH from Bastion to Cassandra CQL"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "tcp"
      port           = 9042
      description    = "Cassandra CQL from Bastion"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "tcp"
      port           = 7000
      description    = "Cassandra Inter-node"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "tcp"
      port           = 7001
      description    = "Inter-node communication (TLS)"
      v4_cidr_blocks = ["192.168.1.0/24"]
    },
    {
      protocol       = "tcp"
      port           = 7199
      description    = "Cassandra JMX"
      v4_cidr_blocks = ["192.168.1.0/24"]
    }
  ]
}