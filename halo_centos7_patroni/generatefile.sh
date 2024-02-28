#!/bin/bash
set -e

HOSTNAME="`hostname`"
hostip=$(ping ${HOSTNAME} -c 1 -w 1 | sed '1{s/[^(]*(//;s/).*//;q}')

# generate etcd
generate_etcd_conf() {
    echo "name: ${HOSTNAME}" >> /home/${USER}/etcd.yml
    echo "data-dir: /home/${USER}/etcddata" >> /home/${USER}/etcd.yml
    echo "listen-client-urls: http://0.0.0.0:2379" >> /home/${USER}/etcd.yml
    echo "advertise-client-urls: http://${hostip}:2379" >> /home/${USER}/etcd.yml
    echo "listen-peer-urls: http://0.0.0.0:2380" >> /home/${USER}/etcd.yml
    echo "initial-advertise-peer-urls: http://${hostip}:2380" >> /home/${USER}/etcd.yml
    ip_temp="initial-cluster: "
    array=(${HOSTLIST//,/ })
    for host in ${array[@]}
    do
        ip_temp+="${host}=http://${host}:2380,"
    done
    echo ${ip_temp%?} >> /home/${USER}/etcd.yml
    echo "initial-cluster-token: etcd-cluster-token" >> /home/${USER}/etcd.yml
    echo "initial-cluster-state: new" >> /home/${USER}/etcd.yml
}

# generate patroni
generate_patroni_conf() {
    echo "scope: ${CLUSTER_NAME}" >> /home/${USER}/postgresql.yml
    echo "namespace: /${SERVICE_NAME}/ " >> /home/${USER}/postgresql.yml
    echo "name: ${HOSTNAME} " >> /home/${USER}/postgresql.yml
    echo "restapi: " >> /home/${USER}/postgresql.yml
    echo "  listen: ${hostip}:8008 " >> /home/${USER}/postgresql.yml
    echo "  connect_address: ${hostip}:8008 " >> /home/${USER}/postgresql.yml
    echo "etcd: " >> /home/${USER}/postgresql.yml
    echo "  host: ${hostip}:2379 " >> /home/${USER}/postgresql.yml
    echo "  username: ${ETCD_USER} " >>  /home/${USER}/postgresql.yml
    echo "  password: ${ETCD_PASSWD} " >> /home/${USER}/postgresql.yml
    echo "bootstrap: " >> /home/${USER}/postgresql.yml
    echo "  dcs: " >> /home/${USER}/postgresql.yml
    echo "    ttl: 30 " >> /home/${USER}/postgresql.yml
    echo "    loop_wait: 10  " >> /home/${USER}/postgresql.yml
    echo "    retry_timeout: 10   " >> /home/${USER}/postgresql.yml
    echo "    maximum_lag_on_failover: 1048576 " >> /home/${USER}/postgresql.yml
    echo "    postgresql: " >>  /home/${USER}/postgresql.yml
    echo "      use_pg_rewind: true  " >>  /home/${USER}/postgresql.yml
    echo "      use_slots: true  " >>  /home/${USER}/postgresql.yml
    echo "      parameters:  " >>  /home/${USER}/postgresql.yml
    echo "  initdb:  " >>  /home/${USER}/postgresql.yml
    echo "  - encoding: UTF8  " >>  /home/${USER}/postgresql.yml
    echo "  - data-checksums  " >>  /home/${USER}/postgresql.yml
    echo "  pg_hba:   " >>  /home/${USER}/postgresql.yml
    echo "  - host replication ${USER} 0.0.0.0/0 md5  " >>  /home/${USER}/postgresql.yml
    echo "  - host all all 0.0.0.0/0 md5  " >>  /home/${USER}/postgresql.yml
    echo "postgresql:  " >>  /home/${USER}/postgresql.yml
    echo "  listen: 0.0.0.0:5432  " >>  /home/${USER}/postgresql.yml
    echo "  connect_address: ${hostip}:5432  " >>  /home/${USER}/postgresql.yml
    echo "  data_dir: ${PG_DATADIR}  " >>  /home/${USER}/postgresql.yml
    echo "  bin_dir: ${PG_BINDIR}  " >>  /home/${USER}/postgresql.yml
    echo "  pgpass: /tmp/pgpass  " >>  /home/${USER}/postgresql.yml
    echo "  authentication:  " >>  /home/${USER}/postgresql.yml
    echo "    replication:  " >>  /home/${USER}/postgresql.yml
    echo "      username: ${USER}  " >>  /home/${USER}/postgresql.yml
    echo "      password: ${PASSWD}  " >>  /home/${USER}/postgresql.yml
    echo "    superuser:  " >>  /home/${USER}/postgresql.yml
    echo "      username: ${USER}  " >>  /home/${USER}/postgresql.yml
    echo "      password: ${PASSWD}  " >>  /home/${USER}/postgresql.yml
    echo "    rewind:  " >>  /home/${USER}/postgresql.yml
    echo "      username: ${USER}  " >>  /home/${USER}/postgresql.yml
    echo "      password: ${PASSWD}  " >>  /home/${USER}/postgresql.yml
    echo "  parameters:  " >>  /home/${USER}/postgresql.yml
    echo "    unix_socket_directories: '.'  " >>  /home/${USER}/postgresql.yml
    echo "    wal_level: hot_standby  " >>  /home/${USER}/postgresql.yml
    echo "    max_wal_senders: 10  " >>  /home/${USER}/postgresql.yml
    echo "    max_replication_slots: 10  " >>  /home/${USER}/postgresql.yml
    echo "tags:  " >>  /home/${USER}/postgresql.yml
    echo "    nofailover: false  " >>  /home/${USER}/postgresql.yml
    echo "    noloadbalance: false  " >>  /home/${USER}/postgresql.yml
    echo "    clonefrom: false  " >>  /home/${USER}/postgresql.yml
    echo "    nosync: false  " >>  /home/${USER}/postgresql.yml
}

# ........ 省略部分内容