
variable "zone" {                                # Используем переменную для передачи в конфиг инфраструктуры
  description = "Use specific availability zone" # Опционально описание переменной
  type        = string                           # Опционально тип переменной
  default     = "ru-central1-a"
}

variable "name" {
  description = "Имя_инстанса"
  type        = string
}

variable "platform_id" {
  description = "Тип платформы (например, standard-v2)"
  type        = string
  default     = "standard-v3"
}

variable "cores" {
  description = "Количество vCPU # Определяет количество vCPU"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Объем RAM в ГБ # Определяет объем RAM в гигабайтах"
  type        = number
  default     = 8
}

variable "core_fraction" {
  description = "Гарантированная доля CPU в процентах # Определяет гарантированную долю CPU в процентах"
  type        = number
  default     = 100
}

variable "image_id" {
  description = "ID образа для загрузочного диска"
  type        = string
  default     = "fd8jjccig145ofgp5b9u"
}

variable "disk_size" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = <<-EOT
    Type of the boot disk. Тип загрузочного диска
    Network SSD (network-ssd): Fast network drive; SSD network block storage.
    Network HDD (network-hdd): Standard network drive; HDD network block storage.
    Non-replicated SSD (network-ssd-nonreplicated): Enhanced performance network drive without redundancy.
    Ultra high-speed network storage with three replicas (SSD) (network-ssd-io-m3): High-performance SSD offering the same speed as network-ssd-nonreplicated, plus redundancy.
    Local disk drives on dedicated hosts.
  EOT
  type        = string
  default     = "network-ssd"
}

variable "network_interfaces" {
  description = "Список сетевых интерфейсов"
  type = list(object({
    subnet_id          = string
    ip_address         = optional(string)
    nat                = optional(bool, false)
    security_group_ids = optional(list(string), [])
  }))
}

variable "ssh_key_path" {
  description = "Путь к SSH-ключу"
  type        = string
}

variable "role" {
  description = "Роль сервера"
  type        = string
  default     = true
}
