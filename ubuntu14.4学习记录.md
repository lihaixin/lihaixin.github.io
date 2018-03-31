## 开通ppp转发
	modprobe ip_nat_pptp
	echo 1 > /proc/sys/net/ipv4/ip_forward
	echo 1 > /proc/sys/net/ipv4/tcp_syncookies
  


## 修改密码和SSH端口

	passwd
	vi /etc/ssh/sshd_config
	service ssh restart

## 升级系统安装必要包

	apt-get update  -y && apt-get upgrade -y
	dpkg --get-selections | grep linux-image
	apt-cache search linux-image
	apt-get install lrzsz iftop mtr curl
	apt-get purge linux-image-4.4.0-*[0-9]*-generic linux-image-extra-4.4.0-*[0-9]*-generic -y
	apt-get install linux-image-4.4.0-47-generic linux-image-extra-4.4.0-47-generic
	wget  http://www.gigsgigscloud.com/cn/downloads/serverspeeder.sh&& bash serverspeeder.sh


## 手动安装低版本docker

	apt-get install -y apt-transport-https ca-certificates wget software-properties-common
	curl -fsSL https://apt.dockerproject.org/gpg  | apt-key add -qq
	echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
	apt-get update
	# apt-cache policy docker-engine
	# aptitude install docker-engine
	apt-get install -y docker-engine=1.12.6-0~ubuntu-trusty

## 自动安装最新版本

	curl -sSL https://get.docker.com/ | sh --mirror	Aliyun  国内用
	curl -sSL https://get.docker.com/ | sh

## 下载ctop命令

	wget https://github.com/bcicen/ctop/releases/download/v0.6.1/ctop-0.6.1-linux-amd64 -O /usr/local/bin/ctop
	chmod +x /usr/local/bin/ctop
	
## 登录docker

	docker login

## 生成docker证书

	wlanip=127.0.0.1
	wlandomain1=*.xingke.info
	wlandomain2=*.yixuexuan.com
	docker run --rm -v $(pwd)/.docker:/certs ehazlett/certm -d /certs bundle generate -o=local --host localhost --host 127.0.0.1 --host $wlanip --host $wlandomain1 --host $wlandomain2
	echo "DOCKER_OPTS='--tlsverify -H=unix:///var/run/docker.sock -H=0.0.0.0:2376  --tlscacert=/root/.docker/ca.pem --tlscert=/root/.docker/server.pem --tlskey=/root/.docker/server-key.pem'" >> /etc/default/docker


## 重启docker

	service docker restart

## 安装serverspeeder加速模块


	apt-get install -y linux-image-3.16.0-43-generic linux-image-extra-3.16.0-43-generic
	reboot
	wget  http://www.gigsgigscloud.com/cn/downloads/serverspeeder.sh&& bash serverspeeder.sh


修改内核，加载hybla模块

	cat >> /etc/sysctl.conf << TEMPEOF
	fs.file-max = 51200
	#提高整个系统的文件限制
	net.core.rmem_max = 67108864
	net.core.wmem_max = 67108864
	net.core.netdev_max_backlog = 250000
	net.core.somaxconn = 32400
	#调整内核打开数
	net.ipv4.tcp_syncookies = 1
        net.ipv4.ip_forward=1
	net.ipv4.tcp_tw_reuse = 1
	net.ipv4.tcp_tw_recycle = 0
	net.ipv4.tcp_fin_timeout = 30
	net.ipv4.tcp_keepalive_time = 1200
	net.ipv4.ip_local_port_range = 10000 65000
	net.ipv4.tcp_max_syn_backlog = 8192
	net.ipv4.tcp_max_tw_buckets = 5000
	net.ipv4.tcp_fastopen = 3
	net.ipv4.tcp_rmem = 4096 87380 67108864
	net.ipv4.tcp_wmem = 4096 65536 67108864
	net.ipv4.tcp_mtu_probing = 1
        # 延迟低于100ms，使用htcp模块
	net.ipv4.tcp_congestion_control = hybla
	#net.ipv4.tcp_congestion_control = htcp
	#net.core.default_qdisc=fq
	#net.ipv4.tcp_congestion_control=bbr
	vm.swappiness=10
	TEMPEOF

## 测试本机性能

	wget -qO- https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash

