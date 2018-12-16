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
kubectl create -f cs-deployment.yaml -n TARGET_NAMESPACE
kubectl create -f cs-deployment.yaml -n TARGET_NAMESPACE
```

## Test against local 
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
