# Check connection FROM > TO
## JNLP connnection (1- master and 2-agent): From 1-master: to CJOC:JNLP port, From 2-agent to OC/Master:JNLP port
telnet my-jenkins.com 8443 #It maintains a socket open, so it can be useful to validate if there is a man a middle closing the channel Connection closed by foreign host
curl -IvL -X GET https://www.my-jenkins.com:8443 # curl curl -iL https://jenkins:8443
nc -z -v -w 2 my-jenkins.com 8443 # It will tell if the port is open or not
# Full List LISTEN port
sudo lsof -i -P -n | grep LISTEN # Prefered method, it provides more information including the process. For extended output use sudo
netstat -pnatu | grep LISTEN
# Check if an application is listening to specific PORT (50001)
lsof -i :50001
netstat -ntpl | grep 50001
# Check internal tables of IP packet filter rules in the Linux kernel
sudo iptables -L
# Check an endpoint is reachable
## No proxy
curl -IvL http://example.gov.com:4516/deployit
## Using proxy
curl -x https://proxy.example.com:3128 --proxy-user <username>:<password> -IvL http://example.gov.com:4516/deployit
### Also you can set variables http_proxy, https_proxy, ftp_proxy, no_proxy: https://wiki.archlinux.org/index.php/Proxy_server
### Same proxy can redirect HTTP and HTTPS https://serverfault.com/questions/817680/https-through-an-http-only-proxy
export https_proxy="https://proxy.example.com:3128" ;curl -ILv https://jenkins-updates.cloudbees.com
# Check Domain Names
nslookup google.com
# Configuration files
## network interface
nano /etc/network/interfaces
## network hosts
nano /etc/hosts
