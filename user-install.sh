touch /etc/openvpn/ccd/Helium-Mango
touch /etc/openvpn/ccd/Helium-PC

echo ifconfig-push 10.8.0.2 255.255.255.0 > /etc/openvpn/ccd/Helium-Mango
echo ifconfig-push 10.8.0.4 255.255.255.0 > /etc/openvpn/ccd/Helium-PC

echo "# Location of the config files" >> /etc/openvpn/server.conf
echo client-config-dir ccd >> /etc/openvpn/server.conf
echo "# Route to the network from host to OVPN Server" >>/etc/openvpn/server.conf
echo route 192.168.8.0 255.255.255.0 >> /etc/openvpn/server.conf
echo  "# Tell all clients the Home address" >>/etc/openvpn/server.conf
echo push "route 192.168.8.0 255.255.255.0"  >> /etc/openvpn/server.conf
echo "# DNS-Server for Clients (Mango)">>/etc/openvpn/server.conf
echo push "dhcp-option DNS 192.168.8.1" >> /etc/openvpn/server.conf
