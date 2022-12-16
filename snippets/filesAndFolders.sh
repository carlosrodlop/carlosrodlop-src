# CJE1
## Find de Mesos Tasks where a container was running. That information
find <$SUPPORT_BUNDLE/pse> -name "*<Container_ID>*"
## Search on the worker messages folder all the messages obteined
grep "level=>:error" messages | awk -F":message=>" '{print $2}' | sort | uniq -c| sort -n
grep "level=error" messages | awk -F":msg=" '{print $1}' | sort | uniq -c| sort -n
curl -u admin:*** https://example.com/example-master/ > version.html ; cat version.html | grep jenkins_ver | awk -F"jenkins_ver" '{print $2}' | awk -F"span" '{print $1}'
## Output "><a href="https://release-notes.cloudbees.com/product/CloudBees+Jenkins+Platform+Private+SaaS+Edition">Managed Master 2.190.2.2-rolling</a></

# Jenkins
## Getting exiting reason for a build
for i in $(find "${JENKINS_HOME}/jobs" -name "build.xml"); do grep -H -i "exit(" "$i"; done

# Jenkins application workflow
## Milestones
grep -Rh "jenkins.InitReactorRunner" nodes/master/logs | sort | uniq
## VM
grep "VM" -B 1 038-jenkins.log

# General
## Search for warn messages and count them, removing the first and second column
grep -i warn fe843895-0998-41b7-9d9e-d19ba17bc67f/stdout |  awk '{$1=$2=""; print $0}' | sort | uniq -c | sort -n
## Printing specific elements/columns from a selected strings
grep -Rh "Failure on JSON element" 007-folder.zip.no_8080/nodes | awk '{print $1, $2, $10}'
# List all folder that contains c, inside then grep for " 503 " , excluying feeder...
for i in $(ls|grep c); do echo $i;grep -Ri " 503 " $i | grep -v feeder | cut -d "\"" -f 2 | cut -d "\"" -f 1 ;done
# Filter a log file by 2 timestamps, getting SEVERE and WARNING Messages
sed -n '/2019-01-15 10:33:27/,/2019-01-15 10:33:46/p' "nodes/master/logs/jenkins.log" | grep -e WARNING -e SEVERE
# Filter in multiple log files by 2 timestamps, getting error message case insensitive
for i in $(grep -lR "java.io.IOException: Unexpected termination of the channel") .; do sed -rne '/2018-12-13/,/2018-12-13/ p' ${i} | grep "java.io.IOException: Unexpected termination of the channel"; done
# List files permission recursively from existing folder
ls -lastrhR
# Replace string in a file
sed -i 's#tcp://docker-service<#tcp://docker-service:2375<#g' ${JENKINS_HOME}/config.xml
# Replace string in a file recursivetly
find . -type f -print0 | xargs -0 sed -i 's#package pipelines#package groovy.pipelines#g'
# Find a file recursively (httpd.conf) from a directory
find . -name \httpd.conf -type f
find . -name \*.conf -type f # pattern (substring)
# Find a directory recursively (.git) from a directory and delete them
find . -name \.git -type d -delete
# Create a fresh directory and untar
mkdir '20181023213540-sc' && tar -xf 20181023213540-sc.tar.gz -C $_
# Open partially the support bundle. not corrupted files
jar -xvf supportBundle.example
# Change permissions of a folder recursively
chmod -R ugo+rx jenkins-home
# Change ownername:groupname of a folder recursively
chown -R jenkins:jenkins-group jenkins-home
# Grep recursively only for certain names of files (log in this case)
find ./ -type f -name "log" -print0 | xargs -0 grep -i "NODE_NAME"
# grep on specific selected folders
grep -Ri "hudson.remoting.ChannelClosedException: channel is already closed" $(find . -type d -name "ux-gcc-p1" -o -name "ux-gcc-vm1" -o -name "ux-gcc-vm2" -o -name "ux-scc-vm1" -o -name "ux-scc-vm2" -o -name "ux-scc-vm3")
# add prefix and suffix at the of each line y a file
awk '{print "gpg2 --edit-key \""$0"\" trust quit"}' secrets.acl > secrets.sh
# Assign current user and group to a file
sudo chown $(id -u):$(id -g) $HOME/.kube/config
