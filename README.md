# codescene-kubernetes
## Install Codescene standalone on kubernetes
These instructions have been tested on AWS but should also work for GKE and standard K8S. The only *caveat* is configuring Persistent Storage is environment-specific.
### Installing on AWS EKS 
1. Create an EBS-VOLUME and note the volumeID and size
2. Write the volumeID and size to cs-pv.yaml and cs-pv-claim.yaml
3. Run k8s commands to install from YAML files

## Commands
```
kubectl create -f cs-pv.yaml -n TARGET_NAMESPACE
kubectl create -f cs-pv-claim.yaml -n TARGET_NAMESPACE
kubectl create -f cs-deployment.yaml -n TARGET_NAMESPACE
```
The above creates a permanent volume and mounts it arst /data

# HINTS
*HINT1* You may also wish to define a configMap and put your Codescene config files in it. You can then mount configMap in place of the existing container files so that changes made are preserved on restarts.
*HINT2* In some environments you will also need to define an ingress. The file `cs-ingress.yaml` should get you started.

*HINT3* There are two files (`check_istio.sh` and `debug_istio.sh`)which may be helpful in collecting data when installing Codescene in an Istio Service Mesh.
## Test against local 
*NOTE:* (8003 is an arbitrary port number to connect to the service listening on 3003. You are free to choose a different one.) 
```
kubectl -n codescene port-forward $(kubectl -n codescene get pod -l app=codescene -o jsonpath='{.items[0].metadata.name}') 8003:3003
```
```
http://localhost:8003
```
You will need to create an ingress to access from outside. See https://kubernetes.io/docs/concepts/services-networking/ingress/

## Files
```
├── README.md
├── cs-deployment.yaml
├── cs-pv-claim.yaml
└── cs-pv.yaml
├── cs-ingress.yaml
└── istio
    ├── README.md
    └── codescene-gateway.yaml
```
