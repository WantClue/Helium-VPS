apt update
apt upgrade
apt install iptables

wget https://raw.githubusercontent.com/Angristan/openvpn-install/master/openvpn-install.sh -O debian10-vpn.sh

chmod +x debian10-vpn.sh

export AUTO_INSTALL=y APPROVE_INSTALL=y APPROVE_IP=y IPV6_SUPPORT=y PORT_CHOICE=1 PROTOCOL_CHOICE=1 DNS=3 COMPRESSION_ENABLED=n CUSTOMIZE_ENC=n CLIENT=Helium-Client PASS=1
sudo ./debian10-vpn.sh



iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1240

iptables -A FORWARD -i tun0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i eth0 -o tun0 -p tcp --syn --dport 44158 -m conntrack --ctstate NEW -j ACCEPT

iptables -A FORWARD -i eth0 -o tun0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 44158 -j DNAT --to-destination 10.8.0.2

export AUTO_INSTALL=y 
export APPROVE_INSTALL=y
export APPROVE_IP=y
export IPV6_SUPPORT=y
export PORT_CHOICE=1
export PROTOCOL_CHOICE=1
export DNS=3
export COMPRESSION_ENABLED=n
export CUSTOMIZE_ENC=n
export CLIENT=Helium-PC
export PASS=1
sudo ./debian10-vpn.sh

echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf

sysctl -p

sudo apt-get install iptables-persistent

sudo netfilter-persistent save

sudo netfilter-persistent reload
