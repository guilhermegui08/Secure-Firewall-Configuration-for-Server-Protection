#!/bin/bash 

###############################
# Init. of iptables
###############################

  IPT=/sbin/iptables

  echo "Default policy"
  $IPT -P INPUT DROP
  $IPT -P OUTPUT DROP
  $IPT -P FORWARD DROP

  echo "Flush rules and personalized lists"
  $IPT -F
  $IPT -X

###############################
# STATELESS rules
###############################

# identify the item number in your answers

echo "Allow loopback interface"
#RULE NUMBER #1
$IPT -A INPUT  -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

echo "Prevent ICMP flood"
#RULE NUMBER #2
$IPT -N icmp_flood
$IPT -A icmp_flood -m limit --limit 5/second -j RETURN
$IPT -A icmp_flood -j DROP
$IPT -A INPUT -p icmp -j icmp_flood

echo "Prevent UDP flood"
#RULE NUMBER #3
$IPT -N udp_flood
$IPT -A udp_flood -m limit --limit 10/second --limit-burst 50 -j RETURN
$IPT -A udp_flood -j DROP
$IPT -A INPUT -p udp -j udp_flood

echo "Prevent TCP flood"
#RULE NUMBER #4
$IPT -N syn_flood
$IPT -A syn_flood -p tcp --dport 22 -j RETURN
$IPT -A syn_flood -m limit --limit 50/second --limit-burst 100 -j RETURN
$IPT -A syn_flood -j DROP
$IPT -A INPUT -p tcp --syn -j syn_flood

echo "ICMP packets that must be allowed to guarantee proper network functionality"
#RULE NUMBER #5
$IPT -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type time-exceeded -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type parameter-problem -j ACCEPT



###############################
# STATEFUL rules
###############################  

echo "Default statefull rules"
#RULE NUMBER #6
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Deny and log input invalid packets"
#RULE NUMBER #7
$IPT -A INPUT -m state --state INVALID -j LOG --log-prefix "INVALID IN " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
$IPT -A INPUT -m state --state INVALID -j DROP

echo "Deny and log output invalid packets"
#RULE NUMBER #8
$IPT -A OUTPUT -m state --state INVALID -j LOG --log-prefix "INVALID OUT " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
$IPT -A OUTPUT -m state --state INVALID -j DROP

echo "Allow PING as a client"
#RULE NUMBER #9
$IPT -A OUTPUT -p icmp --icmp-type echo-request -m state --state NEW -j ACCEPT


echo "Allow DNS as a client both UDP and TCP"
#RULE NUMBER #10
$IPT -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
#RULE NUMBER #11
$IPT -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT

echo "Allow http as a client"
#RULE NUMBER #12
$IPT -A OUTPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT

echo "Allow DNS over TLS as a client"
#RULE NUMBER #13
$IPT -A OUTPUT -p tcp --dport 853 -m state --state NEW -j ACCEPT

echo "Allow https as a client, git as a client using https, docket as client using https"
#RULE NUMBER #14
$IPT -A OUTPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT

echo "Allow GIT as a client"
#RULE NUMBER #15
$IPT -A OUTPUT -p tcp --dport 9418 -m state --state NEW -j ACCEPT

echo "Allow WHOIS as a client"
#RULE NUMBER #16
$IPT -A OUTPUT -p tcp --dport 43 -m state --state NEW -j ACCEPT

echo "Allow DOCKER as a client"
#RULE NUMBER #17
$IPT -A OUTPUT -p tcp --dport 8080 -m state --state NEW -j ACCEPT

echo "Allow SSH has a client, git as a client using ssh"  
#RULE NUMBER #18
$IPT -A OUTPUT -p tcp --dport ssh -m state --state NEW -j ACCEPT

echo "Reject DNS - as server"
#RULE NUMBER #19
$IPT -A INPUT -p udp --dport 53 -m state --state NEW -j REJECT --reject-with icmp-port-unreachable
#RULE NUMBER #20
$IPT -A INPUT -p tcp --dport 53 -m state --state NEW -j REJECT --reject-with tcp-reset

echo "Allow PING as a server"
#RULE NUMBER #21
$IPT -A INPUT -p icmp --icmp-type echo-request -m state --state NEW -j LOG --log-prefix "VALID IN " --log-level 4 --log-ip-options
$IPT -A INPUT -p icmp --icmp-type echo-request -m state --state NEW -j ACCEPT

echo "Allow HTTP - as server"
#RULE NUMBER #22
$IPT -A INPUT -p tcp --sport 1024:65535 --dport 80 -m state --state NEW -j LOG --log-prefix "VALID IN " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
$IPT -A INPUT -p tcp --sport 1024:65535 --dport 80 -m state --state NEW -j ACCEPT

echo "Allow HTTPs - as Server"
#RULE NUMBER #23
$IPT -A INPUT -p tcp --sport 1024:65535 --dport 4443 -m state --state NEW -j LOG --log-prefix "VALID IN " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
$IPT -A INPUT -p tcp --sport 1024:65535 --dport 4443 -m state --state NEW -j ACCEPT


echo "Allow HTTP3 - as Server"
#RULE NUMBER #24
$IPT -A INPUT -p udp --sport 1024:65535 --dport 80 -m state --state NEW -j LOG --log-prefix "VALID IN " --log-level 4 --log-ip-options
$IPT -A INPUT -p udp --sport 1024:65535 --dport 80 -m state --state NEW -j ACCEPT
#RULE NUMBER #25
$IPT -A INPUT -p udp --sport 1024:65535 --dport 443 -m state --state NEW -j LOG --log-prefix "VALID IN " --log-level 4 --log-ip-options
$IPT -A INPUT -p udp --sport 1024:65535 --dport 443 -m state --state NEW -j ACCEPT

echo "Allow SSH has a Server"  
#RULE NUMBER #26
$IPT -A INPUT -p tcp --sport 1024:65535 --dport ssh -m state --state NEW -j LOG --log-prefix "VALID IN " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
$IPT -A INPUT -p tcp --sport 1024:65535 --dport ssh -m state --state NEW -j ACCEPT

echo "Allow multiplexer local port"
#RULE NUMBER #27
$IPT -A INPUT -p tcp --sport 1024:65535 --dport 443 -m state --state NEW -j ACCEPT

echo "END"
