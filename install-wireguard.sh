apt update 
apt upgrade -y
apt install iptables 
apt install wireguard 
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
-------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
[Interface]
ListenPort = 51820
PrivateKey = VPS-privatekey
Address = 10.0.1.1/24
MTU = 1420

PostUp = iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1240
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostUp = iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn --dport 44158 -m conntrack --ctstate NEW -j ACCEPT
PostUp = iptables -A FORWARD -i eth0 -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostUp = iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 44158 -j DNAT --to-destination 10.0.1.2
PostDown = iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1240
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i eth0 -o wg0 -p tcp --syn --dport 44158 -m conntrack --ctstate NEW -j ACCEPT
PostDown = iptables -D FORWARD -i eth0 -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostDown = iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 44158 -j DNAT --to-destination 10.0.1.2

[Peer]
PublicKey = hotspot-publickey
AllowedIPs = 10.0.1.2/32

[Peer]
PublicKey = PC-publickey
AllowedIPs = 10.0.1.3/32

------------------------------------------------------------------------------------------------------------
nano /etc/wireguard/wg0.conf

Alles einfügen

--------------------------------------------------------------------------------------
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl -p 
systemctl start wg-quick@wg0
systemctl status wg-quick@wg0.service


Wiregard PC Client https://www.wireguard.com/install/  Windows Installer

[Interface]
PrivateKey = PC-privatekey 
Address = 10.0.1.3/32
DNS = 1.1.1.1

[Peer]
PublicKey = VPS-publickey
AllowedIPs = 0.0.0.0/0
Endpoint = IPDESSERVER:51820


der Mango ist das Erreichbar unter der 10.0.1.2  wenn verbunden


-------------------------------------------------------------------------------------------------

Mango VPN hinzfügen Manuelle Einagbe 

Schnittstelle:

IP-Adresse   : 10.0.1.2/32

privater Schlüssel: hotspot-privatekey

auf Port hören : 51820

DNS:  nicht drauf gehen :) sonst könnt Ihr das wiederholen


MTU (Default:1420) :  1420

Peer:

öffentlicher Schlüssel :  VPS-publickey

Endpunkt : IPDESSERVER:51820     ( IP von Server + Port )

erlaubte IPs : 	0.0.0.0/0,::/0
