#!/bin/bash  
  
# 设置错误检查，如果任何命令返回非零状态，则立即退出  
set -e  
  
# 导入默认环境变量和生成文件  
source /home/${USER}/runtime/env-defaults  
source /home/${USER}/runtime/generatefile  
  
# 设置 PostgreSQL 相关路径  
PG_DATADIR=/home/${USER}/pgdata  
PG_BINDIR=/home/${USER}/bin  
  
# 定义 configure_patroni 函数  
configure_patroni() {  
    # 生成配置文件  
    generate_etcd_conf  
    generate_patroni_conf  
    generate_vip_conf  
      
    # 启动 etcd  
    etcdcount=${ETCD_COUNT}  
    count=0  
    ip_temp=""  
    array=(${HOSTLIST//,/ })  
    for host in ${array[@]}  
    do  
        ip_temp+="http://${host}:2380,"  
    done  
    etcd --config-file=/home/${USER}/etcd.yml >/home/${USER}/etcddata/etcd.log 2>&1 &  
      
    while [ $count -lt $etcdcount ]  
    do  
        line=(`etcdctl --endpoints=${ip_temp%?} endpoint health -w json`)  
        count=`echo $line | awk -F"\"health\":true" '{print NF-1}'`  
        echo "waiting etcd cluster"  
        sleep 5  
    done  
      
    # 启动 patroni  
    patroni /home/${USER}/postgresql.yml > /home/${USER}/patroni/patroni.log 2>&1 &  
      
    # 启动 vip-manager  
    sudo vip-manager --config /home/${USER}/vip.yml  
}