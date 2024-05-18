#!/bin/bash

# 升级内核功能needs to be 6.0 or above
function update_kernel() {

#更换阿里源
echo "\
deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse">/etc/apt/sources.list

#更新系统包列表
apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

#安装内核
apt install linux-image-generic-hwe-22.04 -y

#重启机器
reboot

}

# 节点安装功能
function add_user() {

#
adduser holesky

#
echo 'holesky ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#
su - holesky

}

function install_node() {

#
sudo apt-get update -y

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    # 如果 Docker 未安装，则进行安装
    echo "未检测到 Docker，正在安装..."
	# Add Docker's official GPG key:
	sudo apt-get update -y
	sudo apt-get install ca-certificates curl -y
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update -y
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
else
    echo "Docker 已安装。"
fi

#安装git
sudo apt-get install git-all -y

#安装holesky
cd ~ && git clone https://github.com/eth-educators/eth-docker.git && cd eth-docker

./ethd install -y

source ~/.profile

./ethd config

sed -i 's/COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml:grafana.yml:grafana-shared.yml:mev-boost.yml/COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml:grafana.yml:grafana-shared.yml:mev-boost.yml:el-shared.yml:cl-shared.yml/' .env

sed -i 's/CL_P2P_PORT=9000/CL_P2P_PORT=7000/' .env

if [ -f "./ethd" ]; then
    ./ethd up
else
    echo "下载ethd失败，请检查网络连接或URL是否正确。"
fi

 echo "节点已经启动，请使用浏览器打开 本机ip:3000 查看，默认账号密码admin"

}


# 主菜单
function main_menu() {
    clear
    echo "脚本以及教程由推特用户节点服务商@cvprogramer 编写，免费开源，推特关注节点服务商@cvprogramer "
    echo "================================================================"
    echo "节点社区 Telegram 群组:https://t.me/GXRun/1"
    echo "请选择要执行的操作:"
    echo "1. 升级内核"
    echo "2. 新建用户holesky"
	echo "3. 安装rpc客户端"
    read -p "请输入选项（1-3）:"
    case $OPTION in
    1) update_kernel ;;
	2) add_user ;;
    3) install_node ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu



