# Docker daemon
## Debian/ubuntu
sudo service docker start
sudo service docker stop
##Centos/Redhat
sudo systemctl start docker
sudo systemctl stop docker

# Upload Image to DockerHub
## Login
cat ~/.ssh/docker-pass.txt | docker login --username $MY_USER --password-stdin
## From Dockerfile
# Create Image from Dockerfile ("-t" --> it tagges the image simultaneosly )
docker image build -t hello:v0.1 . # v0.1 - Default Dockerfile - docker image build -t <REPO>:<TAG>
docker image build -f Dockerfile-v2 -t hello:v0.2 . # v0.2 - Dockerfile-v2 - docker image build -f <DOCKERFILE> -t <REPO>:<TAG>
# List the images to get the id
docker images ls
# Tag your image (DockerHubUser/Image:version). In case you did not tagged with "build -t". Recommendation: For snapshot version use `latest` tag
docker tag 12a08b001e33 mockcarlosrodloporg/t48913:original
# Push
docker push mockcarlosrodloporg/t48913
## From Container
docker ps -a # get container ID
docker commit -m "adding more users" -a "Test OpenLDAP 72806" f1e52bfbe4b8 carlosrodlop/test-openldap-extended:t.72806

# Cleaning up
docker container stop $(docker container ls -aq)
docker container rm $(docker container ls -aq)
docker image rm -f $(docker image ls -q)
docker rmi -f $(docker images -f "dangling=true" -q)
# How can I keep container running on Kubernetes?
docker run -itd debian
docker run -d debian sleep 300
#Inspect containers
## List container to inspect
docker container ls
## Inspect all information from container id: d60683407a97
docker container inspect d60683407a97
## extract specific information (Mount Points)
docker container inspect -f "{{ json .Mounts }}"  d60683407a97 | python -m json.tool

# Enabling Docker API REST on Docker Host to connect any Remote computer
# Open the `/etc/default/docker` file, search for DOCKER_OPTS and add values
DOCKER_OPTS=' [...] -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock'

# Docker mount
## Use a local mount
docker run -v /foo:/bar brikis98/my-rails-app # docker container run -v HOST_PATH:CONTAINER_PATH [OPTIONS] IMAGE [CMD]
## Create a mount point with docker /graph/volumes/html
docker volume create --name html
docker container run --name www -d -p 8080:80 -v html:/usr/share/nginx/html
docker volume inspect html # To check where that volumen is mounted
