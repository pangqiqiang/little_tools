#!/bin/bash

#项目列表
PROJECTS=("credit_center" "jjd_api" "msg_center" "pay_service")
#项目git地址映射
declare -A GIT_MAP DEPLOY_MAP
GIT_MAP=([credit_center]=git@git.renrenxin.com:infrastructure/credit_center/credit_center.git
[jjd_api]=git@git.renrenxin.com:product/jjd/jjd_api.git
[msg_center]=git@git.renrenxin.com:infrastructure/msg_center/msg_center.git
[pay_service]=git@git.renrenxin.com:infrastructure/pay_center/pay_service.git)
#项目部署地址		 
DEPLOY_MAP=([credit_center]=/home/work/app/credit_center/
[jjd_api]=/home/work/app/jjd_api/
[msg_center]=/home/work/app/msg_center/
[pay_service]=/home/work/app/pay_service/)
#maven地址
MAVEN_PATH="/home/work/app/maven"
#java
java_path="/home/work/app/jdk"

#创建工作目录
function get_workspace(){
  work_space=${GIT_MAP[$1]##*/}
  work_space=${work_space%.*}
  work_space=$HOME/$work_space  
}

#部署工作目录
function get_src(){
  get_workspace $1
  if [ -d $work_space ];then
    cd $work_space
  else
    cd $HOME
    git clone ${GIT_MAP[$1]}
    [ $? -ne 0 ] && exit 1
  fi
  confirm_branch
  git pull origin $branch
}

function backup() {
  [ -d ${DEPLOY_MAP[$1]} ] || mkdir -p ${DEPLOY_MAP[$1]}
  cd  ${DEPLOY_MAP[$1]}
  ls | grep -Eq "*\.jar$"
  if [ $? -eq 0 ]; then 
    tar -czf $1.bak.tar.gz  *.jar
    cp $1.bak.tar.gz $work_space
    rm -f ${DEPLOY_MAP[$1]}/*
  fi
}

function build() {
  cd $work_space
  git checkout $branch
  $MAVEN_PATH/bin/mvn clean && $MAVEN_PATH/bin/mvn package -Dmaven.test.skip=true -U
}

function deploy() {
  cd $work_space
  find . -maxdepth 2 -path "*/target/*.jar" -exec cp -a {} ${DEPLOY_MAP[$1]}  \;
}

function rollback()  {
  get_workspace $1
  rm -rf ${DEPLOY_MAP[$1]}/*
  cd $work_space
  echo $work_space
  tar -xf $1.bak.tar.gz -C ${DEPLOY_MAP[$1]}
}

function restart() {
	cd ${DEPLOY_MAP[$1]}
	pids=`ps aux | grep -i $1|grep -i java | grep -v grep|awk '{print $2}'`
  pid_count=`ps aux | grep -i $1|grep -i java | grep -v grep|wc -l`
  if [ $pid_count -ge 1 ]; then
    for pid in $pids; do
      kill -9 $pid
    done
  fi

	proc=`find ${DEPLOY_MAP[$1]} -name *.jar` 
  nohup $JAVA_HOME/bin/java -Xms800m -Xmx800m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:MaxNewSize=512m  -jar $proc &
  sleep 3
  echo "部署重启完成，等待片刻测试，如果服务未启动请查看对应项目目录下nohup.out"
}


function confirm_projects(){
  cat << EOF
----------------------------------------
|***************工程列表***************|
----------------------------------------
`for ((i=0;i<${#PROJECTS[*]};i++));do echo -e "\033[35m $i)${PROJECTS[$i]}\033[0m"; done`
EOF
	read -p "选择需要部署工程: "  project_item
	project_name=${PROJECTS[$project_item]}
	[ -z "$project_name" ] && echo "you choose an invalid item" && exit 1 
}

function confirm_branch(){
  cd $work_space
	branches=(`git branch -r | grep -v '\->'|sed -r 's!^\s*origin/!!'`)
  cat << EOF
----------------------------------------
|***************选择分支***************|
----------------------------------------
`for ((i=0;i<${#branches[*]};i++));do echo -e "\033[35m $i)${branches[$i]}\033[0m"; done`
EOF
read -p "选择需要部署分支: "  index
branch=${branches[index]}
}

function confirm_action(){
	cat <<EOF
---------------------------------------
|**************部署or回退？****************|
`echo -e "\033[35m 1)部署工程\033[0m"`
`echo -e "\033[35m 2)回滚到最近一次部署\033[0m"`
EOF
read -p "选择需要进行操作: "  action
}
   

#获取需要操作工程名
confirm_projects
#确认动作
confirm_action
case $action in
	1)
	get_src $project_name
	build $project_name
	backup $project_name
	deploy $project_name
	restart $project_name
	;;
	2)
	rollback $project_name
	restart $project_name
	;;
	*)
	echo "invalid action you choosed"
	exit 1
	;;
esac
