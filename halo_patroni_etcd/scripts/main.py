import yaml
import socket
import os
import configure_patroni
# import configure_supervisord
import configure_etcd


def get_container_ip():
    container_ip = socket.gethostbyname(socket.gethostname())
    return container_ip

def get_container_name():
    container_name = os.environ.get('HOSTNAME')
    if container_name is None:
        container_name = socket.gethostname()
    return container_name

container_ip = get_container_ip()
container_name = get_container_name()

#运行patroni脚本
configure_patroni.run(container_name,container_ip)

#运行etcd脚本
configure_etcd.run(container_name,container_ip)

# etcd_command = "etcd --config-file=/etc/etcd/conf.yml"
# etcd_logfile = "/var/log/etcd_service.log"

# patroni_command = "patroni  /etc/patroni/patroni.yml"
# patroni_logfile = "/var/log/patroni_service.log"

