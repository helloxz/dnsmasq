#!/bin/bash
#####		一键安装DNSmasq脚本		#####
#####		Author:xiaoz			#####

#自动放行端口
function chk_firewall() {
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 53 -j ACCEPT
		iptables -I INPUT -p udp --dport 53 -j ACCEPT
		service iptables save
		service iptables restart
	else
		firewall-cmd --zone=public --add-port=53/tcp --permanent 
		firewall-cmd --zone=public --add-port=53/udp --permanent 
		firewall-cmd --reload
	fi
}

#安装
yum -y install dnsmasq

#获取服务器公网IP
osip=$(curl http://https.tn/ip/myip.php?type=onlyip)

#设置上游DNS
echo "nameserver 119.29.29.29" >> /etc/resolv.dnsmasq.conf
echo "nameserver 114.114.114.114" >> /etc/resolv.dnsmasq.conf

#修改配置文件
#载入DNS
sed -i 's%#resolv-file=%resolv-file=\/etc\/resolv.dnsmasq.conf%g' /etc/dnsmasq.conf
sed -i 's/#strict-order/strict-order/g' /etc/dnsmasq.conf
#设置监听IP
sed -i "s%#listen-address=%listen-address=${osip}%g" /etc/dnsmasq.conf
#科学上网配置
wget -O /etc/dnsmasq.d/gfw.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq

#设置定时任务
echo "10 2 * * * wget -O /etc/dnsmasq.d/gfw.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq && service dnsmasq restart" >> /etc/crontab

#防火墙放行端口
chk_firewall

#重载服务
service dnsmasq restart

#####		安装完成，请注意安全组放行53 tcp/upd端口		#####