variable "zone" {
  description = "Use specific availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "folder_id" {
  description = "ID каталога в Yandex Cloud"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloud_id" {
  type      = string
  sensitive = true
  default   = ""
}

variable "ssh_base_path" {
  type        = string
  description = "Базовая директория для SSH-ключей"
  default     = "C:/Users/valar/.ssh"
}

variable "bastion_key_name" {
  type        = string
  description = "Имя файла ключа для доступа к бастину (без расширения)"
  default     = "key_to_bastion"
}

variable "cluster_key_name" {
  type        = string
  description = "Имя файла ключа для доступа от бастина к кластеру"
  default     = "bastion_to_cluster_key"
}

variable "cassandra_ip_suffixes" {
  description = "Список суффиксов IP-адресов для узлов Cassandra"
  type        = list(number)
  default     = [197]
}

variable "bastion_ip_suffixes" {
  description = "Список суффиксов IP-адресов для узлов бастионa"
  type        = list(number)
  default     = [198]
}

