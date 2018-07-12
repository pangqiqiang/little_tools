#!/usr/bin/python -tt
# -*- coding: utf-8 -*-
#-*- coding:GBK -*- 

import string
import sys
import os
import time
import datetime
import commands
import optparse
#import json
import socket
import httplib
from threading import Thread
from threading import Event
import smtplib
import email.MIMEMultipart
import email.MIMEText
import email.MIMEBase
#import MySQLdb
#print "成字符串"

# 从列表转化成字符串，各元素间用分号隔
def arrayToStr(A):
        s = "";
        for a in A:
                s += a + ";"
        return s

# 发送邮件，参数1是日期，参数2是项目名，参数3是发送信息正文 
def sendMail(To, project, record_in_file):
        From = 'monitoring@16801.com'
        Cc = []
        msgs = []
        msgs.append(record_in_file)
        msg_content = string.join(msgs, "")

        server = smtplib.SMTP()
        server.connect("smtp.16801.com")
        server.login('monitoring@16801.com','chujianj8')

        main_msg = email.MIMEMultipart.MIMEMultipart()
#        text_msg = email.MIMEText.MIMEText(msg_content,'plain','utf8')  
        text_msg = email.MIMEText.MIMEText(msg_content,'plain','GBK')  
        main_msg.attach(text_msg)

        main_msg['From'] = From
        main_msg['To'] = arrayToStr(To)
        main_msg['Cc'] = arrayToStr(Cc)
        main_msg['Subject'] = project
        main_msg['Date'] = email.Utils.formatdate( )
        fullText = main_msg.as_string( )

        try:
                server.sendmail(From, To + Cc, fullText)
        finally:
                server.quit()


# ------------------ start ------------------------
if __name__=="__main__":
        receiver = sys.argv[1].split(",")
        subject  = unicode(sys.argv[2],'utf-8');
        content  = unicode(sys.argv[3],'utf-8');
        sendMail(receiver, subject, content)
