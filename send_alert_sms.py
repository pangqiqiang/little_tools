#!/usr/bin/env python
#-*-coding:utf-8-*-

import requests
import sys, os, getopt
import json
from datetime import datetime

url = 'http://smssh1.253.com/msg/send/json'    #url
headers = {'Content-Type': 'application/json'}  #必带请求头信息
data_body = {}    #请求体body信息

host = os.getenv("HOSTNAME")   #主机名
account = "xxxxx"
password = "xxxxxx"
msg = "【253云通讯】"
phone = ""
event = ""
#sendtime = datetime.now().strftime('%Y%m%d%H%M')


# 从命令行获取事件和服务器参数(h--host, m--msg, p--phone)
opts, args = getopt.getopt(sys.argv[1:], "h:e:p:")
for op, value in opts:
    if op == "-h":
	    host = value
    if op == "-e":
	    event = value
    if op == "-p":
	    phone = phone + value

msg = "%s   host:%s-event:%s" % (msg, host, event)		
data_body["account"] = account
data_body["password"] = password
data_body["phone"] = phone
data_body["msg"] = msg
		
try:
    rest = requests.post(url, headers=headers, 
	    data=json.dumps(data_body).encode("utf-8"))
except Exception as e:
    print(e)


#print(rest.text)

