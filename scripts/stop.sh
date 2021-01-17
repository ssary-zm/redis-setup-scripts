#!/bin/bash

echo "please input redis type(single, ha, cluster, proxy, all):"

read redis_type


count=`ps -ef | grep -i -E 'codis|redis' | grep -v -E 'grep|stop|cli' | wc -l`
(( $count == 0 )) && echo "there is no redis program" && exit 0

function stop_single_redis()
{
	ps -ef | grep redis | grep 6379 | grep -v -E 'grep|stop|cli' | awk '{print $2}' | xargs kill -9
	(( $? == 0 )) && echo "kill redis single succeed"
}

function stop_ha_redis()
{
	ps -ef | grep redis | grep 638* | grep -v -E 'grep|stop|cli' | awk '{print $2}' | xargs kill -9
	(( $? == 0 )) && echo "kill redis ha succeed"
}

function stop_cluster_redis()
{
	ps -ef | grep redis | grep 800* | grep -v -E 'grep|stop|cli' | awk '{print $2}' | xargs kill -9
	(( $? == 0 )) && echo "kill redis cluster succeed"
}

function stop_proxy_redis()
{
	rm -rf /tmp/codis
	ps -ef | grep codis | grep -v -E 'grep|stop|cli' | awk '{print $2}' | xargs kill -9
	(( $? == 0 )) && echo "kill codis succeed"
}

function stop_redis()
{
	if [[ $redis_type == 'all' ]]; then
		stop_single_redis
		stop_ha_redis
		stop_cluster_redis
		stop_proxy_redis
	else
		eval "stop_${redis_type}_redis"
	fi
}

stop_redis
