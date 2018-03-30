# 在virtualbox下安装alpine

docker 非常的好,打算在主系统下安装[alpine](http://alpinelinux.org/about) 虚拟机，然后在上面部署[docker](https://www.docker.com/),打造一个轻型的可定制的路由器

## 准备工作

* 电脑安装了[virtualbox](https://www.virtualbox.org/)软件，且安装好VirtualBox Extension Pack
* 下载[alpine iso](http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/alpine-virt-3.7.0-x86_64.iso) 到磁盘，这里我下载64位 VIRTUAL版本 


## 安装alpine

- 创建虚拟机，挂载iso文件
- 然后启动，见下图，然后输入`root`按回车进入
- 然后输入`setup-alpine`安装alpine
	- 首先是需要输入键盘格式,直接回车
	- 主机名：alpine-docker
	- 网卡：eth0
	- 然后自动获得ip,选择dhcp,手动设置no
	- 设置管理员密码 :alpine-docker
	- 输入时区 Asia/Shanghai 直接输入就行了。 
	- 网络代理：none
	- 选择镜像：f  自动检测
	- 安装openssh
	- NTP客户端 chrony
	- 进行格式化硬盘 ,输入sda,
	- 类型使用sys ,  sys 才是把文件写入硬盘
	- 提示擦除磁盘，选择y

- 磁盘写入完后提示重启，卸载iso,然后输入`reboot`重启


## 配置alpine

### 开启ssh远程登录

默认 alpine 没有开启root远程登录权限,配置允许root登录，当然这个是测试方便，因为我们alpine存放在局域网里

	echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
	/etc/init.d/sshd restart



### 安装docker

修改apk源为国内
```bash
vi /etc/apk/repositories
#/media/cdrom/apks
#/media/cdrom/apks
http://mirrors.ustc.edu.cn/alpine/v3.7/main  
http://mirrors.ustc.edu.cn/alpine/v3.7/community  
#http://dl-4.alpinelinux.org/alpine/v3.7/main     
#http://dl-4.alpinelinux.org/alpine/v3.7/community
#http://dl-4.alpinelinux.org/alpine/edge/main     
#http://dl-4.alpinelinux.org/alpine/edge/community
#http://dl-4.alpinelinux.org/alpine/edge/testing

```
参考官方指令安装docker

	apk update && apk add docker
	rc-update add docker boot
	


修改docker 仓库镜像

	echo "DOCKER_OPTS=\"$DOCKER_OPTS --registry-mirror=https://registry.docker-cn.com\"" >> /etc/conf.d/docker
	service docker start

按照docker 管理界面：


	docker run -d -p 9000:9000 --label owner=portainer \
	       --restart=always --name=ui \
	       -v /var/run/docker.sock:/var/run/docker.sock \
	       portainer/portainer
	

访问：`http://url:9000` 修改`admin`密码：`portainer`设置隐藏owner=portainer

###设置静态IP

根据自己的网络环境设置静态ip

`vi /etc/network/interfaces` 

	 #lo
	    auto lo
	    iface lo inet loopback
	#dhcp自动获取配置ip
	    auto eth0
	    iface eth0 inet dhcp
	#static配置静态ip
	    iface eth0 inet static
	          address 192.168.1.169
	          netmask 255.255.255.0
	          gateway 192.168.1.1
	        
修改DNS为国内
       
	echo "nameserver 114.114.114.114 " >/etc/resolv.conf 
	echo "nameserver 114.114.115.115" >/etc/resolv.conf 

重启网络 

	/etc/init.d/networking restart
       
       
##配置alpine虚拟机开机后台运行

### linux

	 /etc/rc.local
	su li -c "vboxmanage startvm 'alpine --type headless &"

mint linux下使用开机启动程序里添加自定义命令

### windows

 执行命令：
 
	 vi alpine.bat  放到开机启动文件夹里
	 VBoxManage.exe startvm “alpine” –type headless 
	 
 
alpine表示的是要启动的虚拟机的名称，headless表示不显示界面。

>如果将以上所有的命令写入到.bat文件里，放置在桌面上，那么只需简单双击即可启动虚拟机，而且不显示任何画面。这时VirtualBox虚拟机作为一个后台进程在执行。由于不显示画面，所以不会出现VirtualBox增强工具导致的一系列问题，而且也节省了系统资源，将更多的资源用来计算而不是画面展示。


## 总结

这样一个 alpine linux 系统就安装好了，配置好docker和portainer管理界面，很方便我们打造模块化的路由器

## 参考资料
- https://wiki.alpinelinux.org/wiki/Installation
- https://wiki.alpinelinux.org/wiki/Setup-alpine
- https://wiki.alpinelinux.org/wiki/Configure_Networking 
- https://www.lakevilladom.com/2016/10/23/Alpine-Linux%E9%85%8D%E7%BD%AE%E6%93%8D%E4%BD%9C%E8%AF%B4%E6%98%8E/
