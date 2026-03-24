module "network" {
  source    = "./modules/network"

  name = "uno_network"
}

module "subnetwork" {
  source    = "./modules/subnet"

  subnet_name    = "uno_subnetwork"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.1.0/24"]
  network_id     = module.network.network_id
}

module "sg_bastion" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-bastion"
  ingress_rules = [
    {
      protocol       = "tcp"
      port           = 22
      description    = "SSH from Admin PC"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol       = "tcp"
      port           = 3128
      description    = "HTTP Proxy from Internal Network"
      v4_cidr_blocks = ["192.168.1.0/24"]
    }
  ]
  egress_rules = [
    {
      protocol       = "tcp"
      port           = 22
      description    = "SSH from Admin PC"
      v4_cidr_blocks = ["192.168.1.197/32"]
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
      description    = "Cassandra CQL to Node A"
      v4_cidr_blocks = ["192.168.1.197/32"]
    },
    {
      protocol       = "tcp"
      port           = 9043
      description    = "Cassandra CQL to Node A (Port 9043)"
      v4_cidr_blocks = ["192.168.1.197/32"]
    },
    {
      protocol       = "tcp"
      port           = 9044
      description    = "Cassandra CQL to Node A (Port 9044)"
      v4_cidr_blocks = ["192.168.1.197/32"]
    }
  ]
}

module "sg_cassandra_cluster" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-cassandra-nodes"
  ingress_rules = [
    {
      protocol       = "tcp"
      port           = 22
      description    = "SSH from Bastion"
      v4_cidr_blocks = ["192.168.1.198/32"]
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
      port           = 7199
      description    = "Cassandra JMX"
      v4_cidr_blocks = ["192.168.1.0/24"]
    }
  ]
  egress_rules = [
    {
      protocol       = "TCP"
      port           = 3128
      description    = "Allow HTTP Proxy to Bastion"
      v4_cidr_blocks = ["192.168.1.198/32"]
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
    }
  ]

}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

module "vm-a" {
  source    = "./modules/instance"

  name          = "a_server"
  platform_id   = "standard-v3"
  zone          = "ru-central1-a"
  cores         = 2
  memory        = 8
  core_fraction = 100
  image_id      = data.yandex_compute_image.ubuntu.id
  disk_size     = 20
  disk_type     = "network-ssd"
  subnet_id     = module.subnetwork.subnet_id
  security_group_ids = [module.sg_cassandra_cluster.security_group_id]
  nat           = false
  internal_ip   = "192.168.1.197"
  ssh_key_path  = format("%s/%s.pub", pathexpand(var.ssh_base_path), var.cluster_key_name)
}

module "vm-b" {
  source    = "./modules/instance"

  name          = "b_server"
  platform_id   = "standard-v3"
  zone          = "ru-central1-a"
  cores         = 2
  memory        = 8
  core_fraction = 100
  image_id      = data.yandex_compute_image.ubuntu.id
  disk_size     = 20
  disk_type     = "network-ssd"
  subnet_id     = module.subnetwork.subnet_id
  security_group_ids = [module.sg_bastion.security_group_id]
  internal_ip   = "192.168.1.198"
  ssh_key_path  = format("%s/%s.pub", pathexpand(var.ssh_base_path), var.bastion_key_name)
}

resource "null_resource" "copy_private_key_to_vm1" {
  depends_on = [module.vm-b]

  connection {
    type        = "ssh"
    host        = module.vm-b.external_ip_address
    user        = "ubuntu"
    private_key = file("${format("%s/%s", pathexpand(var.ssh_base_path), var.bastion_key_name)}")
  }

  provisioner "file" {
    source      = "${format("%s/%s", pathexpand(var.ssh_base_path), var.cluster_key_name)}"
    destination = "/home/ubuntu/.ssh/${var.cluster_key_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/${var.cluster_key_name}",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/${var.cluster_key_name}"
    ]
  }
}
