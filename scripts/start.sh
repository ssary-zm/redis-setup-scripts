#!/bin/bash

echo "please input redis type (single, ha, cluster, proxy, all):"

read redis_type

codis_path='/opt/codis-3.2.2'
redis_path='/opt/redis-5.0.7/src'
log_path='/opt/redis/log'
conf_path='/opt/redis/conf'
data_path='/opt/redis/data'

prepare_single_conf()
{
	cp ../conf/redis.conf $conf_path/redis-single-6379.conf
	sed -i 's/6379/6379/g' $conf_path/redis-single-6379.conf
}

prepare_ha_conf()
{
	cp ../conf/redis.conf $conf_path/redis-ha-6380.conf
	cp ../conf/redis.conf $conf_path/redis-ha-6381.conf
	sed -i 's/6379/6380/g' $conf_path/redis-ha-6380.conf
	sed -i 's/6379/6381/g' $conf_path/redis-ha-6381.conf
}

prepare_cluster_conf()
{
	cp ../conf/redis.conf $conf_path/redis-cluster-8000.conf
	cp ../conf/redis.conf $conf_path/redis-cluster-8001.conf
	cp ../conf/redis.conf $conf_path/redis-cluster-8002.conf
	cp ../conf/redis.conf $conf_path/redis-cluster-8003.conf
	cp ../conf/redis.conf $conf_path/redis-cluster-8004.conf
	cp ../conf/redis.conf $conf_path/redis-cluster-8005.conf
	sed -i 's/6379/8000/g' $conf_path/redis-cluster-8000.conf
	sed -i 's/6379/8001/g' $conf_path/redis-cluster-8001.conf
	sed -i 's/6379/8002/g' $conf_path/redis-cluster-8002.conf
	sed -i 's/6379/8003/g' $conf_path/redis-cluster-8003.conf
	sed -i 's/6379/8004/g' $conf_path/redis-cluster-8004.conf
	sed -i 's/6379/8005/g' $conf_path/redis-cluster-8005.conf
	sed -i 's/# cluster-config-file/cluster-config-file/g' $conf_path/redis-cluster-800*.conf
	sed -i 's/# cluster-enabled/cluster-enabled/g' $conf_path/redis-cluster-800*.conf
	sed -i 's/# cluster-node-timeout/cluster-node-timeout/g' $conf_path/redis-cluster-800*.conf
}

prepare_proxy_conf()
{
	cp ../conf/redis-proxy.conf $conf_path/redis-proxy-9000.conf
	cp ../conf/redis-proxy.conf $conf_path/redis-proxy-9001.conf
	cp ../conf/redis-proxy.conf $conf_path/redis-proxy-9002.conf
	cp ../conf/redis-proxy.conf $conf_path/redis-proxy-9003.conf
	cp ../conf/redis-proxy.conf $conf_path/redis-proxy-9004.conf
	cp ../conf/redis-proxy.conf $conf_path/redis-proxy-9005.conf
	cp ../conf/proxy.toml $conf_path/proxy-1000.toml
	cp ../conf/proxy.toml $conf_path/proxy-1001.toml
	cp ../conf/proxy.toml $conf_path/proxy-1002.toml
	sed -i 's/6379/9000/g' $conf_path/redis-proxy-9000.conf
	sed -i 's/6379/9001/g' $conf_path/redis-proxy-9001.conf
	sed -i 's/6379/9002/g' $conf_path/redis-proxy-9002.conf
	sed -i 's/6379/9003/g' $conf_path/redis-proxy-9003.conf
	sed -i 's/6379/9004/g' $conf_path/redis-proxy-9004.conf
	sed -i 's/6379/9005/g' $conf_path/redis-proxy-9005.conf
	sed -i 's/11080/11081/g' $conf_path/proxy-1000.toml
	sed -i 's/11080/11082/g' $conf_path/proxy-1001.toml
	sed -i 's/11080/11083/g' $conf_path/proxy-1002.toml
	sed -i 's/19000/1000/g' $conf_path/proxy-1000.toml
	sed -i 's/19000/1001/g' $conf_path/proxy-1001.toml
	sed -i 's/19000/1002/g' $conf_path/proxy-1002.toml
}

start_single_redis()
{
	rm -f $data_path/6379/*
	nohup "${redis_path}/redis-server" $conf_path/redis-single-6379.conf --port 6379 > $log_path/6379.log 2>&1 &
	sleep 1
	flushdb 6379
}

start_ha_redis()
{
	rm -f $data_path/638*/* $data_path/638*/*
	nohup "${redis_path}/redis-server" $conf_path/redis-ha-6380.conf --port 6380 > $log_path/6380.log 2>&1 &
	nohup "${redis_path}/redis-server" $conf_path/redis-ha-6381.conf --port 6381 --slaveof 127.0.0.1 6380 > $log_path/6381.log 2>&1 &
	sleep 1
	flushdb 6380
}

start_cluster_redis()
{
	rm -f $data_path/800*/*
	nohup "${redis_path}/redis-server" $conf_path/redis-cluster-8000.conf > $log_path/8000.log 2>&1 &
	nohup "${redis_path}/redis-server" $conf_path/redis-cluster-8001.conf > $log_path/8001.log 2>&1 &
	nohup "${redis_path}/redis-server" $conf_path/redis-cluster-8002.conf > $log_path/8002.log 2>&1 &
	nohup "${redis_path}/redis-server" $conf_path/redis-cluster-8003.conf > $log_path/8003.log 2>&1 &
	nohup "${redis_path}/redis-server" $conf_path/redis-cluster-8004.conf > $log_path/8004.log 2>&1 &
	nohup "${redis_path}/redis-server" $conf_path/redis-cluster-8005.conf > $log_path/8005.log 2>&1 &
	sleep 1
	echo "yes" | ${redis_path}/redis-cli --cluster create 127.0.0.1:8000 127.0.0.1:8001 127.0.0.1:8002 127.0.0.1:8003 127.0.0.1:8004 127.0.0.1:8005 --cluster-replicas 1
	
	flushdb 8000 8001 8002 8003 8004 8005
}

start_proxy_redis()
{
	rm -f $data_path/900*/*
	# 启动所有节点，6个Server，3个Proxy，1个Dashboard，1个Fe
	nohup "${codis_path}/codis-server" $conf_path/redis-proxy-9000.conf > $log_path/9000.log 2>&1 &
	nohup "${codis_path}/codis-server" $conf_path/redis-proxy-9001.conf > $log_path/9001.log 2>&1 &
	nohup "${codis_path}/codis-server" $conf_path/redis-proxy-9002.conf > $log_path/9002.log 2>&1 &
	nohup "${codis_path}/codis-server" $conf_path/redis-proxy-9003.conf > $log_path/9003.log 2>&1 &
	nohup "${codis_path}/codis-server" $conf_path/redis-proxy-9004.conf > $log_path/9004.log 2>&1 &
	nohup "${codis_path}/codis-server" $conf_path/redis-proxy-9005.conf > $log_path/9005.log 2>&1 &
	nohup "${codis_path}/codis-proxy" "--config=$conf_path/proxy-1000.toml" "--dashboard=18080" "--log=$log_path/1000.log" "--log-level=INFO" "--ncpu=4" "--pidfile=/var/run/proxy-1000.pid" > "$log_path/1000.out" 2>&1 < /dev/null &
	nohup "${codis_path}/codis-proxy" "--config=$conf_path/proxy-1001.toml" "--dashboard=18080" "--log=$log_path/1001.log" "--log-level=INFO" "--ncpu=4" "--pidfile=/var/run/proxy-1001.pid" > "$log_path/1001.out" 2>&1 < /dev/null &
	nohup "${codis_path}/codis-proxy" "--config=$conf_path/proxy-1002.toml" "--dashboard=18080" "--log=$log_path/1002.log" "--log-level=INFO" "--ncpu=4" "--pidfile=/var/run/proxy-1002.pid" > "$log_path/1002.out" 2>&1 < /dev/null &
	nohup "${codis_path}/codis-dashboard" "--config=$conf_path/dashboard.toml" "--log=$log_path/18080.log" "--log-level=INFO" "--pidfile=/var/run/dashboard.pid" > "$log_path/18080.out" 2>&1 < /dev/null &
	nohup "${codis_path}/codis-fe" "--assets-dir=/opt/codis-3.2.2/assets" "--filesystem=/tmp/codis" "--log=$log_path/9090.log" "--pidfile=/var/run/9090.pid" "--log-level=INFO" "--listen=0.0.0.0:9090" > "$log_path/9090.out" 2>&1 < /dev/null &
	# 纳管Proxy节点
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --create-proxy --addr=127.0.0.1:11081
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --create-proxy --addr=127.0.0.1:11082
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --create-proxy --addr=127.0.0.1:11083
	# 创建分组
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --create-group --gid=1
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --create-group --gid=2
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --create-group --gid=3
	# 添加Server至分组
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --group-add --gid=1 --addr=127.0.0.1:9000
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --group-add --gid=1 --addr=127.0.0.1:9001
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --group-add --gid=2 --addr=127.0.0.1:9002
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --group-add --gid=2 --addr=127.0.0.1:9003
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --group-add --gid=3 --addr=127.0.0.1:9004
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --group-add --gid=4 --addr=127.0.0.1:9005
	# 形成主备关系
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --promote-server --gid=1 --addr=127.0.0.1:9000
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --sync-action --create --addr=127.0.0.1:9001
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --promote-server --gid=2 --addr=127.0.0.1:9002
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --sync-action --create --addr=127.0.0.1:9003
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --promote-server --gid=3 --addr=127.0.0.1:9004
	${codis_path}/codis-admin --dashboard=127.0.0.1:18080 --sync-action --create --addr=127.0.0.1:9005
	# 平均分配slots
	${codis_path}/codis-admin --dashboard=127.0i.0.1:18080 --rebalance --confirm

	sleep 1
	flushdb 9000 9001 9002 9003 9004 9005
}

function flushdb()
{
	for port in $*
	do   
		redis-cli -h 127.0.0.1 -p $port flushdb > /dev/null	
	done 
}

start_all_redis()
{
	start_single_redis
	start_ha_redis
	start_cluster_redis
	start_proxy_redis
}

prepare_all_conf()
{
	prepare_single_conf
	prepare_ha_conf
	prepare_cluster_conf
	prepare_proxy_conf
}
	
start_redis()
{
	eval "start_${redis_type}_redis"
	(( $? == 0 )) && echo "redis $redis_type start succeed"
}

prepare_conf()
{
	eval "prepare_${redis_type}_conf"
}

if [ ! -d $log_path ];then
	mkdir -vp $log_path
fi

if [ ! -d $data_path ];then
	mkdir -vp $data_path
fi

if [ ! -d $conf_path ];then
	mkdir -vp $conf_path
fi

prepare_conf

start_redis
