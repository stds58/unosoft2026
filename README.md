Создать Docker Compose скрипт для развертки кластера из трех инстансов cassandra, 
причем каждый из них должен быть доступен из основной (локальной) сети по отдельному ip адресу.

Задание

    На машине А (ubuntu 24.04 lts) в локальной сети с ip 192.168.1.197 
    запускается скрипт docker-compose для поднятия 3 образов с ip адресами 192.168.1.200-202.

    Затем с машины Б (ubuntu 24.04 lts) из той же локальной сети с ip 192.168.1.198 
    необходимо подключиться через cqlsh к каждой из машин-образов.

    Настроить ssh для возможности подключения к 1.200 с 1.197
    Все приведённые операции необходимо задокументировать и описать инструкцией с командами и объяснениями в Readme
    Добавить скриншот результата в Readme.


Решение

```text
в яндекс облаке создаются 2 вм (вм-а и бастион)
у вм-а отключаем nat,а на бастион ставим прокси, чтобы вм-а мог достучаться до внешнего мира.
на вм-а ставим докер и создаём контейнеры с нодами кассандры

начало работы
в яндекс облаке сделайте авторизованный ключ authorized_key.json и положите его в папку terraform

создайте backend-config.tfvars
    bucket     = "xxx"
    key        = "terraform.tfstate"
    region     = "ru-central1"
    access_key = "xxx"
    secret_key = "xxx"

создайте terraform.tfvars
    cloud_id         = "xxx"
    folder_id        = "xxx"
    ssh_base_path    = "C:/Users/<имя пользователя>/.ssh"
    bastion_key_name = "ssh ключ для подключения от вашего компьютера к бастиону"
    cluster_key_name = "ssh ключ для подключения с бастиона к вм-а"

перейдите в папку terraform
cd terraform

последовательно запустите команды
terraform init -backend-config=backend-config.tfvars
terraform validate
terraform plan
terraform apply -auto-approve

после создания ресурсов в терминале увидите вывод типа
Changes to Outputs:
  - connect_to_a_server          = "ssh -t -i C:/Users/xxx/.ssh/<bastion_key_name> ubuntu@xxx.xxx.xxx.xxx \"ssh -i ~/.ssh/<cluster_key_name> ubuntu@192.168.1.197\"" -> null
  - connect_to_b_server          = "ssh -i ~/.ssh/<bastion_key_name> ubuntu@158.160.115.104" -> null
  - external_ip_address_b_server = "xxx.xxx.xxx.xxx" -> null
  - internal_ip_address_a_server = "192.168.1.197" -> null
  - internal_ip_address_b_server = "192.168.1.198" -> null

в новом терминале перейдите в папку с ансиблем
cd ansible

запустите плейбук
wsl ansible-playbook -i inventory.ini playbook.yml

теперь можно зайти на бастион и подключиться к кассандре
cqlsh 192.168.1.197 9042

к сожалению у меня не получилось в облаке сделать так чтоб бастион видел ноды кассандры на отдельных ip
в ветке main у нод один ip, в ветке feature у нод разные ip, но в пределах вм-а

как вариант есть решение с докером на винде
https://github.com/stds58/unosoft

```
