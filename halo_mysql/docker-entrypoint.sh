#!/usr/bin/env bash
set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)

# usage: file_env VAR [DEFAULT]
# ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		printf >&2 'error: both %s and %s are set (but are exclusive)\n' "$var" "$fileVar"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(<"${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# print large warning if POSTGRES_PASSWORD is long
# error if both POSTGRES_PASSWORD is empty and POSTGRES_HOST_AUTH_METHOD is not 'trust'
# print large warning if POSTGRES_HOST_AUTH_METHOD is set to 'trust'
# assumes database is not set up, ie: [ -z "$DATABASE_ALREADY_EXISTS" ]
docker_verify_minimum_env() {
	# check password first so we can output the warning before postgres
	# messes it up
	if [ "${#HALO_PASSWORD}" -ge 100 ]; then
		cat >&2 <<-'EOWARN'
			WARNING: The supplied HALO_PASSWORD is 100+ characters.
			This will not work if used via PASSWORD with "psql".
		EOWARN
	fi

	if [ -z "$HALO_PASSWORD" ]; then
		# The - option suppresses leading tabs but *not* spaces. :)
		cat >&2 <<-'EOE'
			Error: Database is uninitialized and superuser password is not specified.
			       You must specify HALO_PASSWORD to a non-empty value for the
			       superuser. For example, "-e HALO_PASSWORD=password" on "docker run".
		EOE
		exit 1
	fi

	if [ 'halo' = "$HALO_USER" ]; then
		cat >&2 <<-'EOE'
			********************************************************************************
				ERROR:  role "halo" already exists. You can use another name
			********************************************************************************
		EOE
		exit 1
	fi

}

# initialize empty PGDATA directory
# this is also where the database user is created, specified by `HALO_USER` env
# 初始化数据库动作/ 根据用户输入的参数创建数据库
docker_init_database_dir() {
	#当PGDATA文件夹为空时，初始化数据库
	pg_ctl init -D /data/halo
	#修改HBA配置文件
	echo 'host    all             all             0/0                 md5' >>/data/halo/pg_hba.conf
	echo 'host    replication     replica         0/0                 md5' >>/data/halo/pg_hba.conf

	echo "修改postgresql.conf"
	sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /data/halo/postgresql.conf
	sed -i "s/#port = 1921/port = 1921/" /data/halo/postgresql.conf
	sed -i "s/max_connections = 100/max_connections = 1000/" /data/halo/postgresql.conf
	sed -i "s/#work_mem = 4MB/work_mem = 16MB/" /data/halo/postgresql.conf
	sed -i "s/#wal_buffers = -1/wal_buffers = 16MB/" /data/halo/postgresql.conf
	sed -i "s/#checkpoint_completion_target = 0.9/checkpoint_completion_target = 0.9/" /data/halo/postgresql.conf
	sed -i "s/max_wal_size = 1GB/max_wal_size = 8GB/" /data/halo/postgresql.conf
	sed -i "s/min_wal_size = 80MB/min_wal_size = 2GB/" /data/halo/postgresql.conf
	sed -i "s/#default_statistics_target = 100/default_statistics_target = 100/" /data/halo/postgresql.conf
	sed -i "s/#log_destination = 'stderr'/log_destination = 'csvlog'/" /data/halo/postgresql.conf
	sed -i "s/#logging_collector = off/logging_collector = on/" /data/halo/postgresql.conf
	sed -i "s/#random_page_cost = 4.0/random_page_cost = 1.1/" /data/halo/postgresql.conf
	sed -i "s/#maintenance_io_concurrency = 10/maintenance_io_concurrency = 200/" /data/halo/postgresql.conf
	sed -i "s/#wal_log_hints = off/wal_log_hints = on/" /data/halo/postgresql.conf

	#echo "创建归档日志路径"
 	mkdir -p /data/halo/archivedir

	# 开启归档/测试阶段可以不开启
	sed -i "s/#archive_mode = off/archive_mode = on/" /data/halo/postgresql.conf
	sed -i "s/#archive_command = ''/archive_command = 'test ! -f \/data\/halo\/archivedir\/%f \&\& cp %p \/data\/halo\/archivedir\/%f'/" /data/halo/postgresql.conf
	sed -i "s/#restore_command = ''/restore_command = 'cp \/data\/halo\/archivedir\/%f %p'/" /data/halo/postgresql.conf



	if [ $(lscpu |grep '^CPU(s): ' | awk -F " " '{print $1}') == 'CPU(s):' ]
	then
		CPU=$(lscpu |grep '^CPU(s): ' | awk -F " " '{print $2}')
	elif [ $(lscpu |grep '^CPU: ' | awk -F " " '{print $1}') == 'CPU:' ]
	then
		CPU=$(lscpu |grep '^CPU: ' | awk -F " " '{print $2}')
	else
		echo "没有符合的条件"
	fi

	if [ $(free -m|grep '^Mem:' | awk -F " " '{print $1}') == 'Mem:' ]
	then 
		MEM_S=$(free -m|grep '^Mem:' | awk -F " " '{print expr $2/1024*0.4}' | cut -d '.' -f1)GB
	elif [ $(free -m|grep '^内存：' | awk -F " " '{print $1}') ==  '内存：' ]
	then
		MEM_S=$(free -m|grep '^内存：' | awk -F " " '{print expr $2/1024*0.4}' | cut -d '.' -f1)GB
	else
		echo "没有符合的条件"
	fi


	if [ $(free -m|grep '^Mem:' | awk -F " " '{print $1}') == 'Mem:' ]
	then 
		MEM_E=$(free -m|grep '^Mem:' | awk -F " " '{print $2/1024*0.5}' | cut -d '.' -f1)GB
	elif [ $(free -m|grep '^内存：' | awk -F " " '{print $1}') ==  '内存：' ]
	then
		MEM_E=$(free -m|grep '^内存：' | awk -F " " '{print $2/1024*0.5}' | cut -d '.' -f1)GB
	else
		echo "没有符合的条件"
	fi



	sed -i "s/shared_buffers = 128MB/shared_buffers = $MEM_S/" /data/halo/postgresql.conf
	sed -i "s/#effective_cache_size = 4GB/effective_cache_size = $MEM_E/" /data/halo/postgresql.conf
	sed -i "s/#max_worker_processes = 8/max_worker_processes = $CPU/" /data/halo/postgresql.conf
	sed -i "s/#max_parallel_workers = 8/max_parallel_workers = $CPU/" /data/halo/postgresql.conf
	sed -i "s/#max_parallel_workers_per_gather = 2/max_parallel_workers_per_gather = 4/" /data/halo/postgresql.conf
	sed -i "s/#max_parallel_maintenance_workers = 2/max_parallel_maintenance_workers = 4/" /data/halo/postgresql.conf




	echo "开启MySQL模式"
	sed -i "s/#standard_parserengine_auxiliary = 'on'/standard_parserengine_auxiliary = 'on'/"  /data/halo/postgresql.conf
	sed -i "s/#second_listener_on = false/second_listener_on = 1/"  /data/halo/postgresql.conf
	sed -i "s/#second_port = 3307/second_port = 3306/"  /data/halo/postgresql.conf
	# 根据版本修改日志体现版本
	sed -i "s/#mysql.halo_mysql_version = '5.7.32-log'/mysql.halo_mysql_version = '8.0.21-log'/"  /data/halo/postgresql.conf
	sed -i "s/#mysql.ci_collation = true/mysql.ci_collation = true/"  /data/halo/postgresql.conf  # 字符序不区分大小写
	sed -i "s/#database_compat_mode = 'postgresql'/database_compat_mode = 'mysql'/"  /data/halo/postgresql.conf





	
	echo "启动halo数据库"
	pg_ctl start



	echo "创建用户名和密码"
	psql -c "CREATE USER $HALO_USER SUPERUSER PASSWORD '$HALO_PASSWORD'; "






	echo "安装MySQL扩展"
	psql -c "create extension aux_mysql cascade; "
	


	echo "针对MySQL扩展创建用户"
	psql -c "set password_encryption='mysql_native_password'; "
	psql -c "CREATE USER $HALO_MYSQL_USER SUPERUSER PASSWORD '$HALO_MYSQL_PASSWORD'; "
			

}

# Loads various settings that are used elsewhere in the script
# This should be called before any other functions
docker_setup_env() {
	file_env 'HALO_PASSWORD'     #管理员密码，比如带上此参数
	file_env 'HALO_USER' 'admin' #创建管理员名称

	#创建数据库，默认为halo /halo0root：管理库，群集管理使用，请不要删除,默认使用Oracle模式
	# file_env 'HALO_DB' 'mysql'  
	#MySQL应用的用户
	file_env 'HALO_MYSQL_USER' 'halo_mysql'
	file_env 'HALO_MYSQL_PASSWORD' '12345'



	# 判断是否初始化了数据
	declare -g DATABASE_ALREADY_EXISTS
	: "${DATABASE_ALREADY_EXISTS:=}"
	# look specifically for PG_VERSION, as it is expected in the DB dir
	if [ -s "/data/halo/PG_VERSION" ]; then
		DATABASE_ALREADY_EXISTS='true'
	fi

}

_main() {
	docker_setup_env



	# only run initialization on an empty data directory
	# 当初始化数据目录为空的时候
	if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
		#在这里进行数据库初始化

		#校验是否输入用户名和密码，用户名可以是默认的halo，密码不能为空，并且不能超过100个字符
		docker_verify_minimum_env
		# init an empty database dir for setup
		docker_init_database_dir


		cat <<-'EOM'

			HALO init process complete; ready for start up.

		EOM
	else
		cat <<-'EOM'

			HALO Database directory appears to contain a database; Skipping initialization

		EOM
		#数据不为空，直接启动数据库
		pg_ctl -D /data/halo
	fi


	pg_ctl stop

	postgres
	


}

_main
