[bastion]
%{ for instance in instances ~}
%{ if instance.role == "bastion" ~}
${instance.name} ansible_host=${instance.external_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${bastion_key_path}
%{ endif ~}
%{ endfor ~}

[cassandra]
%{ for instance in instances ~}
%{ if instance.role == "cassandra" ~}
${instance.name} ansible_host=${instance.internal_ip} ansible_user=ubuntu
%{ endif ~}
%{ endfor ~}

[cassandra:vars]
ansible_ssh_private_key_file=${cluster_key_path}

ansible_ssh_common_args='-o ProxyCommand="ssh -i ${bastion_key_path} -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${bastion_external_ip}"'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_args="-o ControlMaster=no -o ControlPersist=no -o StrictHostKeyChecking=no"