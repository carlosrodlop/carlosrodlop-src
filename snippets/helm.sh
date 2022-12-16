################################################################
# REFERENCES:
# https://helm.sh/docs/intro/using_helm/
# https://helm.sh/docs/helm/
# https://artifacthub.io/packages/helm/cloudbees/cloudbees-core
################################################################

# Add Repo to Helm
helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees
helm repo update
# Search (List) for charts
helm search hub jenkins # in the public hub
helm search repo cloudbees # in your repository definition, latest stable
helm search repo cloudbees --version 3.9.0 # in your repository definition, filter by version
# Check values
helm inspect values cloudbees/cloudbees-core # terminal
helm pull --version 3.6.0 cloudbees/cloudbees-core #Download
# List releases vs list repo
helm list
helm list -A #all namespaces
helm repo list
# Upgrade a Realease
helm upgrade -f values.yaml cloudbees-core cloudbees/cloudbees-core -n cloudbees-core
helm upgrade -f values.yaml cloudbees-core -version 3.8.0+a0d07461ae1c cloudbees/cloudbees-core -n cloudbees-core
# Get values from the previos release
helm get values cloudbees-core
# Installing cloudbees-core
## Install with NGINX with Debug, examples
### Remote
helm --v 9 install cloudbees-core-1 cloudbees/cloudbees-core --namespace cloudbees-core-1 --set OperationsCenter.HostName='cloudbees-core.carlosrodlop.site' --set ingress-nginx.Enabled=true --version 3.9.0+c3d55aeaee57
### Rendering locally the template
helm pull --version 3.6.0 cloudbees/cloudbees-core #Download
tar xvzf cloudbees-core-3.9.0+c3d55aeaee57.tgz -C cloudbees-core-3.9.0+c3d55aeaee57 #Decompres and fix
tar -czvf cloudbees-core-3.9.0+c3d55aeaee57.tgz cloudbees-core # compress it back (watch the path)
helm template cloudbees-core-1 cloudbees-core-3.9.0+c3d55aeaee57.tgz --values values.yaml --namespace test-1 > cloudbees-core-test-1.yaml # Render locally the template
kubectl apply -f cloudbees-core.yaml -n test-1
