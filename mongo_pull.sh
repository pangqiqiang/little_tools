#!/bin/bash
mypath=/home/MongoBackup/`date +%Y%m`
if [ ! -d "$mypath" ]; then
  mkdir -p $mypath
fi
#得到前一个小时的时间精确到小时，格式为：2017071013
start=`date +%Y%m%d%H -d '-1 hours'`
year=`echo ${start:0:4}`
month=`echo ${start:4:2}`
day=`echo ${start:6:2}`
hour=`echo ${start:8:2}`
#拉取数据的起始时间确定为：2017-07-10 13:00:00
#Mongoexport的条件备份：-q 特定的格式的时间格式，才能进行时间的大小判断。时间要进行如下转换：
#2017-07-10 13:00:00 --> 1499662800 --> 1499662800000 --> 1499691600000  其中最后一步转换是因为Mongodb的时间和标准时间差8小时。
#然后进行时间范围限定的时候采用固定格式：logonTime:{\$gte:Date($timestamp)
startTime=$year-$month-$day' '$hour':'00':'00
timestamp=`date -d "$startTime" +%s`000
timestamp=`expr $timestamp + 28800000`
end=`expr $timestamp + 3600000`
#-h是mongodb的ip --port是端口  -d是数据库 -c是集合  -q是条件 --type=csv是指定输出文件类型  -o是指定输出路径
#具体参数的意义可以自行搜索。
/home/mongodb/bin/mongoexport -h 114.115.147.192  --port 30000 -d nsitedb -c nSite.authc.sessions -q "{logonTime:{\$gte:Date($timestamp),\$lte:Date($end)}}" -f _id,userId,userName,logonTime,logonIp,logonHost,appName,"editsphere_v1","CDV",state,logoffTime --type=csv -o  $mypath/$year$month$day$hour.csv
sed -i s/","/"|"/g "$mypath/$year$month$day$hour.csv"
sed -i '1d' "$mypath/$year$month$day$hour.csv"

if [ -s "$mypath/$year$month$day$hour.csv"  ]; then
   hdfs dfs -put $mypath/$year$month$day$hour.csv /data/mongo/
fi