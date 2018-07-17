#!/bin/bash

#项目列表
PROJECTS=("credit_center" "jjd_api" "msg_center" "pay_service" "lender" "borrower" "bm" )
#项目git地址映射
declare -A GIT_MAP
GIT_MAP=([credit_center]=git@git.renrenxin.com:infrastructure/credit_center/credit_center.git
[jjd_api]=git@git.renrenxin.com:product/jjd/jjd_api.git
[msg_center]=git@git.renrenxin.com:infrastructure/msg_center/msg_center.git
[pay_service]=git@git.renrenxin.com:infrastructure/pay_center/pay_service.git
[lender]=git@git.renrenxin.com:product/lender/lender.git
[borrower]=git@git.renrenxin.com:product/lender/borrower.git
[bm]=git@git.renrenxin.com:product/lender/bm.git
)

#monitor brache
MON_BRANCH="dev"


#创建工作目录
function get_workspace(){
  work_space=${GIT_MAP[$1]##*/}
  work_space=${work_space%.*}
  work_space=$HOME/$work_space
}



function get_dev_seq(){
  cd $work_space
  branches=(`git branch -r | grep -v '\->'|sed -r 's!^\s*origin/!!'`)
  for ((i=0;i<${#branches[*]};i++));do
	if [ "${branches[$i]}" = "dev" ];then
		echo $i
		break
	fi
  done
}

function get_project_id(){
  for ((i=0;i<${#PROJECTS[*]};i++));do
        if [ "${PROJECTS[$i]}" = "$1" ];then
                echo $i
                break
        fi
  done
}

function check_update(){
  cd $work_space
  git fetch origin
  status=`git diff dev origin/dev`
 if [ -z "$status" ]; then
	echo "ok"
 fi
}


for project in 	${PROJECTS[@]}; do
	get_workspace $project
        update=`check_update`
	if [ ! "$update" = "ok" ]; then
	     dev_id=`get_dev_seq`
	     project_id=`get_project_id $project`
		/usr/bin/expect auto_dep.exp $project_id 1 $dev_id
	fi
        sleep 5
done



