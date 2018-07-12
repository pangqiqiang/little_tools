#!/usr/bin/env python
#-*-coding:utf-8-*-
'''
发送邮件
'''

import smtplib
# import time
from datetime import date, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


class SendEmail(object):
    def __init__(self):
        self.sender = ""
        self.user = ""
        self.passwd = ""
        self.to_list = []
        self.cc_list = []
        self.tag = ""
        self.files = {}
        self.htmls = {}
        self.inhtmls = []
        self.attach = MIMEMultipart()

    def send(self):
        '''
        发送邮件
        '''

        self.basic_attach()
        self.file_attach()
        self.embhtml_attach()
        self.inhtml_attach()

        try:
            server = smtplib.SMTP_SSL("smtp.qq.com", port=465)
            server.login(self.user, self.passwd)
            server.sendmail("<%s>" % self.user, self.to_list,
                            self.attach.as_string())
            server.close()
            print("send email successful")
        except Exception as e:
            print("send email failed %s" % e)

    def basic_attach(self):
        '''
        构造邮件内容
        '''

        if self.tag:
            # 主题,最上面的一行
            self.attach["Subject"] = self.tag
        if self.user:
            # 显示在发件人
            self.attach["From"] = " %s " % self.user
        if self.to_list:
            # 收件人列表
            self.attach["To"] = ";".join(self.to_list)
        if self.cc_list:
            # 抄送列表
            self.attach["Cc"] = ";".join(self.cc_list)

    def file_attach(self):
        '''
        添加附件
        '''
        if self.files:
            # 估计任何文件都可以用base64，比如rar等
            # 文件名汉字用gbk编码代替
            for _name, _file in self.files.iteritems():
                f = open(_file, "rb")
                file = MIMEText(f.read(), "base64", "gb2312")
                file["Content-Type"] = 'application/octet-stream'
                file["Content-Disposition"] = 'attachment; filename="' + _name + '"'
                self.attach.attach(file)
                f.close()

    def embhtml_attach(self):
        '''
        添加内嵌网页
        '''
        if self.htmls:
            for _embname, _html in self.htmls.iteritems():
                ef = open(_html, "rb")
                embhtml = MIMEText(ef.read())
                embhtml["Content-Type"] = 'text/html'
                embhtml["Content-Disposition"] = 'inline; filename="' + \
                    _embname + '"'
                self.attach.attach(embhtml)
                ef.close()

    def inhtml_attach(self):
        '''
        添加内嵌网页，从脚本中写网页内容
        '''
        if self.inhtmls:
            for _inhtml in self.inhtmls:
                intext = MIMEText(_inhtml, "HTML", "utf-8")
                self.attach.attach(intext)


if __name__ == "__main__":
    today = date.today()
    yesterday = today - timedelta(days=1)
    yd = yesterday.strftime('%Y-%m-%d')
    # nowtime = time.strftime("%Y%m%d-%H%M", time.localtime())

    attachment_name = "附件显示名称"
    # print 'assess %s , type is %s' % (assess_analyse_name, type(assess_analyse_name))
    txt1 = "%s" % yd
    # print 'assess %s , type is %s' % (txt1, type(txt1))

    my = SendEmail()
    my.sender = "78733149@qq.com"
    my.user = "78733149@qq.com"
    my.passwd = "phpzzfyrnjyabieb"
    my.to_list = ["pangqiqiang1234@163.com", ]
    #my.cc_list = ["",]
    my.tag = "test"
    #my.files = {attachment_name:"附件",附件显示名称:"附件",}
    #my.htmls = {}
    #my.inhtmls = [txt1,]
    my.send()
