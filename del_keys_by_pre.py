#!/usr/bin/env python
# -*- coding:utf8 -*-

import redis
import sys

#配置信息
CONFIG = {
    "host" : "xxxxxxxxxx",
    "port" : "6379",
    "password": "xxxxxxxxxx",
    "db": 3,
    "max_connections": 10
}



def del_keys(redis_cli, pre, limit):
    count = 0
    all_count = 0
    #pipeline
    pipe = redis_cli.pipeline(transaction=False)
    for id in redis_cli.scan_iter(pre + "*", count=50000):
		count+=1
		all_count+=1
		deal_exception_pipe(pipe.delete, id, all_count)
		if count >= limit:
			deal_exception_pipe(pipe.execute, id, all_count)
			count = 0
    if count >0:
        deal_exception_pipe(pipe.execute, id, all_count)
    print("exec keys count:", all_count)


def deal_exception_pipe(pipe_func, id, all_count):
    try:
        pipe_func(id)
    except Exception as e:
        print(str(e))
        print("exec keys:%s with key:%s" % all_count, id)
        sys.exit(2)


#主程序
if __name__ == "__main__":
    #建立连接池
    try:
        if CONFIG["password"] != "":
            pool = redis.ConnectionPool(**CONFIG)
        else:
            del CONFIG["password"]
            pool = redis.ConnectionPool(**CONFIG)
    except Exception as e:
        print(str(e))
        sys.exit(1)
    #从连接池连接
    conn = redis.Redis(connection_pool=pool)
    prefix = sys.argv[1]
    del_keys(conn, prefix, 5000)
