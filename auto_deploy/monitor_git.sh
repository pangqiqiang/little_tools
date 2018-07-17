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
#项目部署地址
DEPLOY_MAP=([credit_center]=/home/work/app/credit_center/
[jjd_api]=/home/work/app/jjd_api/
[msg_center]=/home/work/app/msg_center/
[pay_service]=/home/work/app/pay_service/
[lender]=/home/work/app/lender/
[borrower]=/home/work/app/borrower/
[bm]=/home/work/app/bm/)
#monitor brache
MON_BRANCH="dev"
#maven地址
MAVEN_PATH="/home/work/app/maven"
#java
java_path="/home/work/app/jdk"
#api接口文档目录
html_home="/home/work/data/html/api/"
#api doc_file
doc_file="api.py"

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
  git pull origin $MON_BRANCH
}


function check_update(){
  cd $work_space
  git fetch origin
  status=`git diff dev origin/dev`
 if [ -z "$status" ]; then
	echo "ok"
 fi
}

function backup() {
  [ -d ${DEPLOY_MAP[$1]} ] || mkdir -p ${DEPLOY_MAP[$1]}
  cd  ${DEPLOY_MAP[$1]}
  ls | grep -Eq "*\.jar$"
  if [ $? -eq 0 ]; then 
    tar -czf $1.bak.tar.gz  *.jar
    cp $1.bak.tar.gz $work_space
    rm -rf ${DEPLOY_MAP[$1]}/*
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
  if [ -f $doc_file ]; then
      [ -d $html_home ] || mkdir -p $html_home
      python api.py 
  fi
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
  sleep 2
  proc=`find ${DEPLOY_MAP[$1]} -name *.jar` 
  nohup $JAVA_HOME/bin/java -Xms800m -Xmx800m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:MaxNewSize=512m  -jar $proc &
  sleep 3
  echo "部署重启完成，等待片刻测试，如果服务未启动请查看对应项目目录下nohup.out"
}

for project in 	${PROJECTS[@]}; do
	get_workspace $project
        update=`check_update`
	if [ ! "$update" = "ok" ]; then
      get_src $project
	  build $project
	  backup $project
	  deploy $project
	  restart $project
	fi
        sleep 5
done



