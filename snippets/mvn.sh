# Get plugin Download dependencies dependencies from command line Group Id:Artifact Id:version:type
mvn org.apache.maven.plugins:maven-dependency-plugin:2.10:get -DremoteRepositories=https://repo.cloudbees.com/content/repositories/dev-connect -Dartifact=com.cloudbees.operations-center.server:operations-center-war:2.46.2.1:war -Dtransitive=false
