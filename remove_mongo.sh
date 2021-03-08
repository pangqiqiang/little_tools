#!/bin/bash
 
#db
dbname=$1
#collection
collectionname=$2
#timestamp
#删除创建时间在3天前的数据
MIN_DATE_NANO=`date -d \`date -d '3 days ago' +%Y%m%d\` +%s%N`;
deletetime=`expr $MIN_DATE_NANO / 1000000`
 
#进入到mongo的bin目录下
cd .../bin
#mongo ip+port
mongodb='./mongo 127.0.0.1:27017'
$mongodb <<EOF
#操作某个db
use ${dbname}
#实际内容可根据需求修改,这里执行删除timestamp(long)小于deletetime的那些记录，类似删除某个时间点之前的数据
db.${collectionname}.remove({timestamp:{\$lt: ${deletetime}}})
exit;
EOF