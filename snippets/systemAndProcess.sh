# Get System identification
uname -a
cat /etc/*release*

# Change to root (no password)
sudo su

# Packages
## Debian/Ubuntu
apt-cache search kubernetes # Search by names
apt-cache show kubernetes-cni # Show full info, take version names from there
## Readhat/Centos
yum --showduplicates list cloudbees* | expand #List all available packages in the remote repository
rpm -qa cloudbees* # Installed package locally

sudo yum install cloudbees-core-oc # Install latest version
sudo yum install cloudbees-core-oc-2.277.4.4-1.1 #Install a specific version (output from yum --showduplicates list cloudbees* | expand)
sudo yum upgrade cloudbees-core-cm-2.289.3.2-1.1 #Upgrade to a specific version

sudo yum remove cloudbees-core-oc # Remove latest version
sudo yum remove cloudbees-core-oc-2.277.4.4-1.1 #Remove a specific version (output from yum --showduplicates list cloudbees* | expand)

# User and Groups
add crodriguezlopez #Add new user (crodriguezlopez) and group. It is a required step if you want to chnage the JENKINS_USER in /etc/sysconfig/cloudbees-core-oc
less /etc/passwd # List existing user id
less /etc/group # List existing groups id

# Services
## Run Services - Different Options https://askubuntu.com/questions/903354/difference-between-systemctl-and-service-commands
systemctl start cloudbees-core-oc
/etc/init.d/cloudbees-core-oc start
services cloudbees-core-oc start
## Logs
systemd-analyze set-log-level debug
### Journalctl is a utility for querying and displaying logs from journald, systemd’s logging service.
journalctl -u cloudbees-core-cm.service # select jourctl logs for a service
journalctl -f # tail of all the logs

# Process
## List processes that are using JAVA, getting the PID
ps -ef | grep cloudbees-core-oc
ps aux | grep cloudbees-core-oc
## List processes run by user cloudbees-core
ps -fu cloudbees-core

# Print running JVM properties
java -XshowSettings:all
jps -lvm
java -XshowSettings:properties -version
