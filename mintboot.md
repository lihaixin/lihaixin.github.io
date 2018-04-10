setup-alpine

apk add sudo

apk --update upgrade


sleep 20

if [ -z "`grep ssroute /etc/iproute2/rt_tables`" ]; then

  echo "244 ssroute" >> /etc/iproute2/rt_tables

fi

/sbin/ip route add default via 172.20.0.254 dev br-747b24d7f70e table  ssroute
/sbin/ip route add 172.20.0.0/16 dev br-747b24d7f70e table  ssroute
/sbin/ip route add 192.168.3.0/24 dev enp0s3 table  ssroute
/sbin/ip route add 172.17.0.0/16 dev docker0 table  ssroute
/sbin/ip route add 127.0.0.0/8 dev lo table  ssroute



ip rule add from 192.168.3.0/24 table ssroute
ip rule add from 192.168.3.107 table main
