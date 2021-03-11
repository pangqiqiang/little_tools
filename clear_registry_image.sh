#!/bin/bash

registry='webdev.quanlishi.cn:5000'
user='dlsimage'
password='SXvCbQV2B'

list_cmd="reg ls -f -u $user -p $password"
tags_cmd="reg tags -f -u $user -p $password"
digest_cmd="reg digest -f -u $user -p $password"
delete_cmd="reg rm -f -u $user -p $password"

function get_repos(){
    repos=$($list_cmd $registry|awk '/^[0-9a-zA-Z_]+\/[0-9a-zA-Z_]+/ {print $1}')
}


function get_tags(){
     repo=$1
     tags=$($tags_cmd $registry/$repo)
}

function get_diget(){
    repo=$1
    tag=$2
    digsum=$($digest_cmd $registry/$repo:$tag)
}

function delete_image(){
    repo=$1
    tag=$2
    get_diget  $repo $tag
    $delete_cmd $registry/${repo}@${digsum}
}

function main(){
    get_repos
    for repo in $repos;do
        get_tags $repo
        num=$(echo $tags|wc -w)
        [ $num -le 20 ] && continue
        history=$[$num-20]
        count=0
        for tag in $(echo $tags | sort -n -t'.' -k1 -k2 -k3);do
            [ $count -ge $history ] && break
            delete_image  $repo $tag
            let count++
	done
    done
}

main
