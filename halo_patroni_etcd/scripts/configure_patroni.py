import yaml

def generate_patroni_config(container_name,container_ip):
    config = {
        "scope": "halo-cluster",
        "namespace": "/service/",
        "name": container_name,
        
        "restapi": {
            "listen": "0.0.0.0:8008",
            "connect_address": f"{container_ip}:8008"
        },
        
        "etcd3": {
            "host": "127.0.0.1:2379",
        },
        
        "log": {
          "level" : "DEBUG",
          "traceback_level": "ERROR",
          "dir": "/opt/patroni/logs",
          "file_size": 26214400,
          "dateformat": "%Y-%m-%d %H:%M:%S",
          "loggers": {
               "patroni.postmaster": "WARNING",
          }
        },

        "bootstrap": {
            "dcs": {
                "ttl": 30,  
                "loop_wait": 10, 
                "retry_timeout": 10, 
                "maximum_lag_on_failover": 1048576, 
                "master_start_timeout": 300, 
                "synchronous_mode": False,
                "use_pg_rewind": True,
                "use_slots": True,
                "postgresql": {
                    "parameters": {
                        # "listen_addresses": "0.0.0.0",
                        # "port": 1921,
                        "unix_socket_directories": "/var/run/halo",
                        # Streaming replication
                        "wal_level": "replica",
                        # "hot_standby": "on",
                        "max_wal_senders": 10,
                        "max_replication_slots": 10,
                        # "wal_log_hints": "on",
                        # end streaming replication
                        # "max_connections": 1000,
                        "work_mem": "16MB",
                        "dynamic_shared_memory_type": "posix",
                        "maintenance_io_concurrency": 200,
                        "checkpoint_completion_target": 0.9,
                        "default_statistics_target": 100,
                        "wal_buffers": "16MB",
                        "random_page_cost": "1.1",
                        # setting of Logging
                        "log_destination": "csvlog",
                        "logging_collector": "on",
                        "log_directory": "diag",
                        "log_filename": "haloserver-%Y-%m-%d_%H%M%S.log",
                        "log_timezone": "Asia/Shanghai",
                        # CLIENT CONNECTION DEFAULTS
                        "datestyle": "iso, ymd",
                        "timezone": "Asia/Shanghai",
                        "lc_messages": "zh_CN.UTF-8",
                        "lc_monetary": "zh_CN.UTF-8",
                        "lc_numeric": "zh_CN.UTF-8",
                        "lc_time": "zh_CN.UTF-8",
                        "default_text_search_config": "pg_catalog.simple",
                        # other settings
                        "archive_mode": "on",
                        "archive_command": "test ! -f /data/halo/archivedir/%f && cp %p /data/halo/archivedir/%f",
                        "restore_command": "cp /data/halo/archivedir/%f %p",
                    },
                    "pg_hba": [
                        "local      all             all                 trust",
                        "host       all             all         0/0     md5",
                        "host       replication     all         0/0     md5",
                        "local      replication     all                 trust",
                    ],
                },
            },
            
           
        },
        "postgresql": {
            "listen": "0.0.0.0:1921",
            "connect_address": f"{container_ip}:1921",
            "data_dir": "/data/halo",
            "database": "halo0root",
            "bin_dir": "/u01/app/halo/product/dbms/14/bin",
            "pgpass": "/opt/patroni/.pgpass",
            "authentication": {
                "replication": {
                    "username": "replica",
                    "password": "halo@123456"
                },
                "superuser": {
                    "username": "halo",
                    "password": "halo0root"
                },
                "rewind": {
                    "username": "patroni",
                    "password": "patroni"
                },
            },
            "parameters": {
                "database_compat_mode": "oracle",
                "standard_parserengine_auxiliary": "on",
                "oracle.use_datetime_as_date": True,
                "transform_null_equals": "off"
            },
            "use_unix_socket": True,
        },
        "watchdog": {
            "mode": "automatic",
            "device": "/watchdog",
            "safety_margin": 5
        },
        "tags": {
            "nofailover": False,
            "noloadbalance": False,
            "clonefrom": False,
            "nosync": False,
        }
    }

    # 导出为YAML格式
    yaml_config = yaml.dump(config)

    # 将配置写入文件
    with open("/etc/patroni/patroni.yml", "w") as f:
        f.write(yaml_config)
    
    
    


def run(container_name,container_ip):
    generate_patroni_config(container_name,container_ip)
    
