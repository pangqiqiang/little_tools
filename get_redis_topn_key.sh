#!/bin/bash
####获取redis各种类型key占空间最大的key及大小#####
####使用：sh get_redis_topn_key.sh  n#############

db_ip=192.168.1.5
db_port=6379
password=''
cursor=0
cnt=100
new_cursor=0

if [ "$password" = "" ];then
    redis_connect="redis-cli -h $db_ip -p $db_port"
else
    redis_connect="redis-cli -h $db_ip -p $db_port -a $password"
fi
    

###scan获取key,new_cursor获取新游标用于下次迭代,结果存临时文件里#######
function get_key(){
    $redis_connect scan $1 count $cnt > scan_tmp_result
    new_cursor=`sed -n '1p' scan_tmp_result`
    sed -n '2,$p' scan_tmp_result > scan_result
}

function get_keyinfo(){
    cat $1 |while read line;do
        key_size=`$redis_connect memory usage $line`
        key_type=`$redis_connect type $line`
        echo $line $key_type $key_size >> "$key_type.txt"    
    done
}


get_key $cursor
get_keyinfo scan_result

#####迭代，当游标再次返回0表示迭代结束
while [ $cursor -ne $new_cursor ];do
    get_key $new_cursor
    get_keyinfo scan_result
done

all_types="string list set hash zset"
for type in $all_types;do
    echo "-----------top $1 $type data type-----------"
    if [[ -f "$type.txt" ]];then
        cat "$type.txt" | sort -nrk3 | sed -n "1,$1p"
    else
        echo "The instance does not have $type data type"
    fi
done


rm -rf scan_tmp_result
rm -rf scan_result
rm -rf string.txt
rm -rf set.txt