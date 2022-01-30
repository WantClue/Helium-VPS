apt update 
apt upgrade -y
apt install iptables -y
apt install wireguard -y
cd/etc/wireguard/
wg genkey | tee VPS-privatekey | wg pubkey > VPS-publickey
wg genkey | tee hotspot-privatekey | wg pubkey > hotspot-publickey
wg genkey | tee PC-privatekey | wg pubkey > PC-publickey

cat VPS-privatekey 
cat VPS-publickey
cat hotspot-privatekey
cat hotspot-publickey
cat PC-privatekey
cat PC-publickey

echo [Interface] >> /etc/wireguard/wg0.conf
echo ListenPort = 51820 >> /etc/wireguard/wg0.conf
echo PrivateKey = >> /etc/wireguard/wg0.conf cat VPS-privatekey >> /etc/wireguard/wg0.conf
echo Address = 10.0.1.1/24 >> /etc/wireguard/wg0.conf
echo MTU = 1420 >> /etc/wireguard/wg0.conf

echo PostUp = iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1240 >> /etc/wireguard/wg0.conf
echo PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE >> /etc/wireguard/wg0.conf
echo PostUp = iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn --dport 44158 -m conntrack --ctstate NEW -j ACCEPT >> /etc/wireguard/wg0.conf
echo PostUp = iptables -A FORWARD -i eth0 -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT >> /etc/wireguard/wg0.conf
echo PostUp = iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 44158 -j DNAT --to-destination 10.0.1.2 >> /etc/wireguard/wg0.conf
echo PostDown = iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1240 >> /etc/wireguard/wg0.conf
echo PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE >> /etc/wireguard/wg0.conf
echo PostDown = iptables -D FORWARD -i eth0 -o wg0 -p tcp --syn --dport 44158 -m conntrack --ctstate NEW -j ACCEPT >> /etc/wireguard/wg0.conf
echo PostDown = iptables -D FORWARD -i eth0 -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT >> /etc/wireguard/wg0.conf
echo PostDown = iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 44158 -j DNAT --to-destination 10.0.1.2 >> /etc/wireguard/wg0.conf

echo [Peer] >> /etc/wireguard/wg0.conf
echo PublicKey = >> /etc/wireguard/wg0.conf cat hotspot-publickey >> /etc/wireguard/wg0.conf
echo AllowedIPs = 10.0.1.2/32 >> /etc/wireguard/wg0.conf

echo [Peer] >> /etc/wireguard/wg0.conf
echo PublicKey = >> /etc/wireguard/wg0.conf cat PC-publickey >> /etc/wireguard/wg0.conf
echo AllowedIPs = 10.0.1.3/32 >> /etc/wireguard/wg0.conf

echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl -p 
systemctl start wg-quick@wg0
systemctl status wg-quick@wg0.service

