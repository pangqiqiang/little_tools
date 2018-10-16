#!/bin/bash

db_host='10.111.33.181'
db_port='3306'
database='jjd' 
db_user='mysqltords'
db_pass='TeNSXaGXbMz8eY86'
res_file='count_result.txt'


MYSQL_CONN="mysql -h$db_host -u$db_user -P$db_port $database -p$db_pass"
sql_for_tablenames="show tables;"
sql_for_count="select count(1) from"

printf "%-50s%-15s%-5s\n" "tablename" "counts" ">1kw?" > $res_file
table_names=`${MYSQL_CONN} -N -e "${sql_for_tablenames}" 2>/dev/null`


for table in ${table_names};do
	(result=`${MYSQL_CONN} -N -e "${sql_for_count} ${table}" 2>/dev/null`
	[ $result -ge 10000000 ] && status="YES" || status=""
	printf "%-50s%-10s%-5s\n" $table $result $status >> $res_file)&
done
wait
