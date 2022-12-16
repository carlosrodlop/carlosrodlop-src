################################################################
# REFERENCES:
#https://kubernetes.io/docs/reference/kubectl/cheatsheet/
################################################################

# CLUSTER

# CONTEXT: Locate your context and cluster
## List all context
kubectl config get-contexts
## Get active context
kubectl config current-context
## Set active context
kubectl config use-context my-context-name
## List for active context > namespaces
kubectl get namespaces

# TROUBLESHOOTING
## Check the cujster is running fine
kubectl cluster-info
## On every node | In the case journalctl is not installed check logs on https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/#looking-at-logs
journalctl -u kubelet |less
# CONNECTIVITY
## Curling cjoc inside its pod
kubectl exec -n cloudbees -ti cjoc-0 -- curl -IvL http://cjoc:80/cjoc
## From Master Pod to CJOC service via DMASTER_OPERATIONSCENTER_ENDPOINT
kubectl exec -n cloudbees -ti teams-dse-team-emea-0 -- curl -IvL http://example.svc.cluster.local/cjoc/
## From CJOC Pod to MASTER_ENDPOINT
kubectl exec -n cloudbees -ti cjoc-0 -- curl -IvL https://example.com/arturo
## From Pod to CJOC via DMASTER_OPERATIONSCENTER_ENDPOINT
## ssh into the cjoc
kubectl exec -n cje -ti cjoc-0 -- bash
## Curling a endpoint (saml metadata) inside the container (jenkins) in a pod (cjoc-0) for the namespace (cloudbees)
kubectl exec -n cloudbees -it cjoc-0 -c jenkins -- curl -IvL https://example.com/nidp/saml2/metadata

# PERFORMANCE, installing Metrics (See https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
kubectl top nodes #Check the overall status of your Kubernetes nodes
kubectl describe node node_example #To get more detailed information for a particular node, there you can distinguish which pod is consuming more memory than others
kubectl top pod -n example_namespace #Pods within a namespace
kubectl describe pod pod_example --container -n example_namespace #Event within a Pod
kubectl top pod pod_example --container -n example_namespace #Container within a Pod


## KUBERNETES EVENTS
# Get last events
kubectl get events --watch # watch here is like tail
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <CB-NAMESPACE> --field-selector involvedObject.kind=Pod
kubectl get events -n <CB-NAMESPACE> --field-selector involvedObject.name=<POD-NAME>
# Get last events for cjoc a pod
kubectl describe pod cjoc-0
kubectl -n <namespace> describe loki-0

## APPLICATION (pod) LOGS
# Tail logs for pod
kubectl logs -f mm2-0
# If your container has previously crashed, you can access the previous container’s crash log with:
kubectl logs --previous ${POD_NAME} ${CONTAINER_NAME}
# Add a custom logger https://support.cloudbees.com/hc/en-us/articles/204880580
kubectl exec -i carlosrodlop-mm-3-v2-0 -- bash -c "mkdir -p /var/jenkins_home/log && cat >/var/jenkins_home/log/ignoreCommitterStrategy.xml <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<log>
  <name>ignoreCommitterStrategy_2</name>
  <targets>
    <target>
      <name>au.com.versent.jenkins.plugins.ignoreCommitterStrategy</name>
      <level>-2147483648</level>
    </target>
  </targets>
</log>
EOF"

#### Creating a deployment in a existing cluster
# Creating a new deployment (which will be running into a new pod)
kubectl --namespace=cje run --image=openjdk:8 my-permanent-agent -ti cat
# Creating a new deployment (which will be running into a new pod)
kubectl --namespace=cje  exec -it $(kubectl --namespace=cje get pods|grep my-permanent-agent|awk '{print $1}')  -- /bin/bash
# Deleting deployment
kubectl --namespace=cje delete deployment my-permanent-agent
# Backup
kubectl scale statefulset/cjoc --replicas=0
cat <<EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: rescue-pod
spec:
  volumes:
    - name: rescue-storage
      persistentVolumeClaim:
       claimName: jenkins-home-cjoc-0
  containers:
    - name: rescue-container
      image: cloudbees/cje-oc:2.107.2.1

EOF

$ kubectl cp ./oc-jenkins_home-backup-files/oc-jenkins-home.tar.gz rescue-pod:/tmp/
$ kubectl exec rescue-pod -it -- tar -xzf /tmp/oc-jenkins-home.tar.gz -C /var/jenkins_home/
$ kubectl delete pod rescue-pod
$ kubectl scale statefulset/cjoc --replicas=1
#### Manage pods based on labels
```
Name:               rs-one-2mqsx
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               ip-172-31-71-179/172.31.71.179
Start Time:         Wed, 30 Oct 2019 11:35:04 +0000
Labels:             system=IsolatedPod
Annotations:        cni.projectcalico.org/podIP: 192.168.0.49/32
Status:             Running
IP:                 192.168.0.49
```
kubectl delete po -l system=IsolatedPod

#### Scale down and up
kubectl scale statefulset/cjoc --replicas=0
kubectl scale statefulset/cjoc --replicas=1nginx-ingress-ingress-nginx-controller
#### Certificates
for i in $(kubectl get cert | awk '{print $1}' | grep tls); do echo "$i \n =======" && kubectl describe cert $i | grep Conditions -A 11; done

# Get pod logs based on label
POD_NAME=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD_NAME -n ingress-nginx > ingress-nginx-controller.log
# Port-forwarding: Access Applications in a Cluster from your local browser
kubectl port-forward $POD_NAME 8080:80
# Check supported extension for a K8 deployment
kubectl api-resources | grep deployment
# Bulk delete
kubectl delete --all statefulset -n namespace.example
kubectl delete --all svc -n namespace.example
kubectl delete --all pods -n namespace.example

# CloudBees Core Inbound-agent definition, check teh ports has been correctly exposed for team.example
# https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-setup-guide/configure-ports-jnlp-agents
kubectl get svc -n cloudbees-core | grep team.example # shows team-example and team-example-jnlp
kubectl get all -n ingress-nginx # shows all the elements from the ingress, except configmap
kubectl get configmap nginx-ingress-ingress-nginx-tcp -n ingress-nginx # in data should contains the tcp port e.g "50004" -> cloudbees/teams-example:50004
kubectl get pod nginx-ingress-ingress-nginx-controller -n ingress-nginx # in port should have the tcp

# Update configmap
kubectl create configmap oc-casc-bundle --from-file=casc/oc/core-casc-export-jenkins -n cloudbees-core -o yaml --dry-run | kubectl replace -f -
