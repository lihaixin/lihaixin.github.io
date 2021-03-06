sleep 20

if [ -z "`grep ssroute /etc/iproute2/rt_tables`" ]; then

  echo "244 ssroute" >> /etc/iproute2/rt_tables

fi

/sbin/ip route add default via 172.20.0.254 dev br-89f4cfb90d2a table  ssroute
/sbin/ip route add 172.20.0.0/16 dev br-89f4cfb90d2a table  ssroute
/sbin/ip route add 192.168.3.0/24 dev eth0 table  ssroute
/sbin/ip route add 172.17.0.0/16 dev docker0 table  ssroute
/sbin/ip route add 127.0.0.0/8 dev lo table  ssroute


ip rule add from 192.168.3.108 table main
ip rule add from 192.168.3.0/24 table ssroute



修改网卡也静态配置


CMD ["/run-dns"]

#!/bin/sh

ss-redir  -s "$SERVER_ADDR" \
                 -p "$SERVER_PORT" \
                -b "$LOCAL_ADDR" \
                -l "$LOCAL_PORT" \
                -m "$METHOD"      \
                -k "$PASSWORD"    \
                -t "$TIMEOUT"     \
                -u                \
                --fast-open $OPTIONS

# 获取大陆地址段
curl -sL http://f.ip.cn/rt/chnroutes.txt | egrep -v '^\s*$|^\s*#' > chnip.txt

# 添加 chnip 表
ipset -N chnip hash:net
for i in `cat chnip.txt`; do echo ipset -A chnip $i >> chnip.sh; done
sh chnip.sh

# 新建 mangle/SS-UDP 链，用于透明代理内网 udp 流量
iptables -t mangle -N SS-UDP

# 放行保留地址、环回地址、特殊地址
iptables -t mangle -A SS-UDP -d 0/8 -j RETURN
iptables -t mangle -A SS-UDP -d 127/8 -j RETURN
iptables -t mangle -A SS-UDP -d 10/8 -j RETURN
iptables -t mangle -A SS-UDP -d 169.254/16 -j RETURN
iptables -t mangle -A SS-UDP -d 172.16/12 -j RETURN
iptables -t mangle -A SS-UDP -d 192.168/16 -j RETURN
iptables -t mangle -A SS-UDP -d 224/4 -j RETURN
iptables -t mangle -A SS-UDP -d 240/4 -j RETURN

# 放行发往 ss 服务器的数据包，注意替换为你的服务器IP

iptables -t mangle -A SS-UDP -d "$SERVER_ADDR" -j RETURN


# 放行大陆地址
iptables -t mangle -A SS-UDP -m set --match-set chnip dst -j RETURN

# 重定向 udp 数据包至 60080 监听端口
iptables -t mangle -A SS-UDP -p udp -j TPROXY --tproxy-mark 0x2333/0x2333 --on-ip 127.0.0.1 --on-port "$LOCAL_PORT"



# 内网 udp 数据包流经 SS-UDP 链
iptables -t mangle -A PREROUTING -p udp -s "$LOCAL_NET" -j SS-UDP


#iptables -L -n -t mangle -v

# 新建 nat/SS-TCP 链，用于透明代理本机/内网 tcp 流量
iptables -t nat -N SS-TCP

# 放行环回地址，保留地址，特殊地址
iptables -t nat -A SS-TCP -d 0/8 -j RETURN
iptables -t nat -A SS-TCP -d 127/8 -j RETURN
iptables -t nat -A SS-TCP -d 10/8 -j RETURN
iptables -t nat -A SS-TCP -d 169.254/16 -j RETURN
iptables -t nat -A SS-TCP -d 172.16/12 -j RETURN
iptables -t nat -A SS-TCP -d 192.168/16 -j RETURN
iptables -t nat -A SS-TCP -d 224/4 -j RETURN
iptables -t nat -A SS-TCP -d 240/4 -j RETURN

# 放行发往 ss 服务器的数据包，注意替换为你的服务器IP
iptables -t nat -A SS-TCP -d  "$SERVER_ADDR" -j RETURN

# 放行大陆地址段
iptables -t nat -A SS-TCP -m set --match-set chnip dst -j RETURN

# 重定向 tcp 数据包至 60080 监听端口
iptables -t nat -A SS-TCP -p tcp -j REDIRECT --to-ports "$LOCAL_PORT"

# 内网 tcp 数据包流经 SS-TCP 链
iptables -t nat -A PREROUTING -p tcp -s "$LOCAL_NET" -j SS-TCP

# 内网数据包源 NAT
iptables -t nat -I POSTROUTING -s "$LOCAL_NET" -j MASQUERADE


# 新建路由表 100，将所有数据包发往 loopback 网卡
ip route add local 0/0 dev lo table 100

# 添加路由策略，让所有经 TPROXY 标记的 0x2333/0x2333 udp 数据包使用路由表 100
ip rule add fwmark 0x2333/0x2333 lookup 100

