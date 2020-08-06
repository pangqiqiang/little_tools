#!/bin/bash

#认证文件
PASS_PATH="/etc/openvpn/server/user/psw-file"
RSA_PATH="/etc/openvpn/server/easy-rsa"
ALL_USER_DIR="/etc/openvpn/server/user/infos"


user_name="$1"
user_pass=$(date +%s | sha256sum | base64 | head -c 12; echo)
#用户目录
user_path="$ALL_USER_DIR/$user_name"

#添加用户到认证文件
cat >>$PASS_PATH<<EOF
$user_name  $user_pass
EOF

#生成认证秘钥
$RSA_PATH/easyrsa build-client-full $user_name nopass

#创建用户信息收集目录
[[ -d $user_path ]] || mkdir -p $user_path

#拷贝认证文件
cp $RSA_PATH/pki/{ca.crt,ta.key}  $user_path
mv $RSA_PATH/pki/issued/$user_name.crt $user_path
mv $RSA_PATH/pki/private/$user_name.key $user_path
#客户端密码文件
cat>>$user_path/pass.txt<<EOF
$user_name
$user_pass
EOF
#拷贝客户端配置文件
cp $ALL_USER_DIR/product.ovpn $user_path
#打包客户端文件
cd $ALL_USER_DIR
tar czf $user_name.tar.gz $user_name