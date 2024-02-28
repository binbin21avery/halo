#!/usr/bin/env bash
set -Eeo pipefail

gosu halo /bin/bash -c 'python3 /tmp/scripts/main.py'


gosu halo /bin/bash -c 'etcd --config-file=/etc/etcd/conf.yml > /tmp/etcd.log 2>&1 &'


gosu halo /bin/bash -c 'patroni /etc/patroni/patroni.yml' 

wait



# echo "$1"

# exec "$1 /etc/patroni/patroni.yml" 



# patroni /etc/patroni/patroni.yml 2>&1 &

# 设置halo数据oracle模式 从这里开始都是postgreSQL需要操作的指令
# pg_ctl init

# pg_conf="/data/halo/postgresql.conf"

# # Oracle模式配置参数
# sed -i "s/#standard_parserengine_auxiliary = 'on'/standard_parserengine_auxiliary = 'on'/" "$pg_conf"
# sed -i "s/#database_compat_mode = 'postgresql'/database_compat_mode = 'oracle'/" "$pg_conf"
# sed -i "s/#oracle.use_datetime_as_date = false/oracle.use_datetime_as_date = true/" "$pg_conf"
# sed -i "s/#transform_null_equals = off/transform_null_equals = off/" "$pg_conf"

# pg_ctl start

# psql -c "CREATE EXTENSION IF NOT EXISTS plorasql;" 

# postgres


#一直到这里结束

#开启patroni
# patroni /etc/patroni/patroni.yml 2>&1 &


# sleep 3600s





# # 日志文件路径
# LOG_FILE="/tmp/server_startup.log"

# # 启动脚本
# start_server "etcd" "etcd --config-file=/etc/etcd/conf.yml" "$LOG_FILE"



# 启动patroni
# start_server "Patroni" "patroni /etc/patroni/patroni.yml" "$LOG_FILE"

# # 等待所有服务器启动完成
# # wait

# echo "All servers started"
# echo "[$(date '+%Y-%m-%d %H:%M:%S')] All servers started" >> "$LOG_FILE"