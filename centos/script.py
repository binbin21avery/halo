import socket
import os
import yaml

def get_container_ip():
    container_ip = socket.gethostbyname(socket.gethostname())
    return container_ip

def get_container_name():
    container_name = os.environ.get('HOSTNAME')
    if container_name is None:
        container_name = socket.gethostname()
    return container_name

def generate_patroni_config(container_ip, container_name):
    config = {
        "scope": "halo-cluster",
        "name": container_name,
        "log": {
          "level" : "INFO",
          "traceback_level": "ERROR",
          "dir": "/opt/" 
        },
        "etcd": {
            "host": f"etcd_host",
            "port": 2379
        },
        "scope": "my_cluster",
        "namespace": "/db/postgresql",
        "name": f"{container_name}",
        "restapi": {
            "listen": "0.0.0.0:8008",
            "connect_address": f"{container_ip}:8008"
        },
        "scope": f"{container_name}"
    }

    # 导出为YAML格式
    yaml_config = yaml.dump(config)

    # 将配置写入文件
    with open("/app/patroni.yml", "w") as f:
        f.write(yaml_config)



def generate_etcd_config(container_name,container_ip,is_cluster,cluster_address=None):
    config = {
        "name": container_name,
        "data-dir": "/opt/etcd-v3.5.0/data",
        "listen-client-urls": f"http://{container_ip}:2379,http://127.0.0.1:2379",
        "advertise-client-urls": f"http://{container_ip}:2379,http://127.0.0.1:2379",
        "listen-peer-urls": "http://192.168.210.15:2380",
        "initial-advertise-peer-urls": f"http://{container_ip}:2380",
        "initial-cluster-token": "halo-etcd-cluster",
        "initial-cluster-state": "new",
    },
    
    if is_cluster and cluster_address is not None and len(cluster_address) > 0:
        config["initial-cluster"] = cluster_address
    else:
        config["initial-cluster"] = f"{container_name}=http://{container_ip}:2380"

    #将配置文件导出yml格式
    yaml_config = yaml.dump(config)
    
    #将配置文件写入到磁盘
    with open("/app/etcd.yml","w") as f:
        f.write(yaml_config)



if __name__ == "__main__":
    container_ip = get_container_ip()
    container_name = get_container_name()

    # 写入环境变量
    os.environ['CONTAINER_IP'] = container_ip
    os.environ['CONTAINER_NAME'] = container_name

    print("Container IP:", container_ip)
    print("Container Name:", container_name)

    generate_patroni_config(container_ip, container_name)
    
    is_cluster = os.getenv("ETCD_CLUSTER_MODE","false").lower() == "true"
    cluster_address = os.getenv("ETCD_CLUSTER_ADDRESSES","")
    generate_etcd_config(container_name,container_ip,is_cluster,cluster_address)