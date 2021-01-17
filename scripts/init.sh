#!/bin/bash

rm -rf /opt/redis/ /opt/redis-5.0.7 /opt/codis-3.2.2

mkdir -p /opt/redis/data /opt/redis/conf /opt/redis/log
mkdir -p /opt/redis/data/6379
mkdir -p /opt/redis/data/6380 /opt/redis/data/6381
mkdir -p /opt/redis/data/8000 /opt/redis/data/8001 /opt/redis/data/8002 /opt/redis/data/8003 /opt/redis/data/8004 /opt/redis/data/8005
mkdir -p /opt/redis/data/9000 /opt/redis/data/9001 /opt/redis/data/9002 /opt/redis/data/9003 /opt/redis/data/9004 /opt/redis/data/9005

cd $(dirname "`find / -name 'redis-setup-scripts'`") 
tar -zxvf ../components/codis-3.2.2.tar.gz -C /opt
tar -zxvf ../components/redis-5.0.7.tar.gz -C /opt
mv /opt/codis3.2.2-go1.8.5-linux /opt/codis-3.2.2
cd /opt/redis-5.0.7/src && make
