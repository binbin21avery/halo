import yaml

def generate_etcd_config(container_name,container_ip):
    config = {
        "name": container_name,
        "data-dir": "/opt/etcd/data",
        "listen-client-urls": f"http://{container_ip}:2379,http://127.0.0.1:2379",
        "advertise-client-urls": f"http://{container_ip}:2379,http://127.0.0.1:2379",
        "listen-peer-urls": f"http://{container_ip}:2380",
        "initial-advertise-peer-urls": f"http://{container_ip}:2380",
        "initial-cluster": f"{container_name}=http://{container_ip}:2380",
        "initial-cluster-token": "halo-etcd-cluster",
        "initial-cluster-state": "new"
    }


    # 导出为YAML格式
    yaml_config = yaml.dump(config)

    # 将配置写入文件
    with open("/etc/etcd/conf.yml", "w") as f:
        f.write(yaml_config)
        
        
def run(container_name,container_ip):
    generate_etcd_config(container_name,container_ip)