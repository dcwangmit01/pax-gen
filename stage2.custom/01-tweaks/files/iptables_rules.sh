# Allow port 80 from localhost (e.g. loopback device)
iptables -A INPUT -i lo -p tcp --dport 80 -j ACCEPT

# Allow port 22 and 443 from RFC1918 local networks
iptables -A INPUT -s 10.0.0.0/8     -p tcp -m multiport --dports 22,443 -j ACCEPT
iptables -A INPUT -s 172.16.0.0/12  -p tcp -m multiport --dports 22,443 -j ACCEPT
iptables -A INPUT -s 192.168.0.0/16 -p tcp -m multiport --dports 22,443 -j ACCEPT

# Drop all other 22,80,443
iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -j DROP
