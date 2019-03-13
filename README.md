# codescene-kubernetes
## Install Codescene standalone on kubernetes
These instructions have been tested on AWS but should also work for GKE and standard K8S. The only *caveat* is configuring Persistent Storage is environment-specific.

### Installing on AWS EKS 
1. Create an EBS-VOLUME and note the volumeID and size
2. Write the volumeID and size to cs-pv.yaml and cs-pv-claim.yaml
3. Run kubectl commands to install directly from YAML files

The PV defition looks like this example (applicable for both EKS and GKE)
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: "codescene-data"
spec:
  capacity:
    storage: 30Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  awsElasticBlockStore:
    volumeID: YOUR-VOLUME-ID 
    fsType: ext4
```
For GKE replace the `awsElasticBlockStorage` with an entry for `gcePersistentDisk:`
```
  gcePersistentDisk:
    pdName: pd-codescene
    fsType: ext4
```
### Installing on Google GKE
1. A dynamic PVC can be defined and then called directly without first creating a volume (as in AWS). 
2. Run kubectl commands to install directly from YAML files

In the above example, the final line `volumeName: ` is not needed for dynamic storage
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: codescene-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
#  volumeName: codescene-data
```

If, however, you want to use a pre-existing, persistent volumne, define the PV and PVC as follows.
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-codescene
spec:
  storageClassName: ""
  capacity:
    storage: 30G
  accessModes:
    - ReadWriteOnce
  gcePersistentDisk:
    pdName: pd-codescene
    fsType: ext4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim-codescene
spec:
  # It's necessary to specify "" as the storageClassName
  # so that the default storage class won't be used, see
  # https://kubernetes.io/docs/concepts/storage/persistent-volumes/#class-1
  storageClassName: ""
  volumeName: pv-codescene
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30G
```
## kubectl commands
```
export TARGET_NAMESPACE=codescene
kubectl create -f cs-pv.yaml -n $TARGET_NAMESPACE  
kubectl create -f cs-pv-claim.yaml -n $TARGET_NAMESPACE
kubectl create -f cs-deployment.yaml -n $TARGET_NAMESPACE
```
The above creates a permanent volume and mounts it arst /data

# HINTS
*HINT1* You may also wish to define a configMap and put your Codescene config files in it. You can then mount configMap in place of the existing container files so that changes made are preserved on restarts.

*HINT2* In Nginx environments you will also need to define an ingress. The file `cs-ingress.yaml` should get you started. For Istio, define a `Gateway` and `VirtualService` in place of an ingress.

*HINT3* There are two files (`check_istio.sh` and `debug_istio.sh`)which may be helpful in collecting data when installing Codescene in an Istio Service Mesh.

## Test against local 
*NOTE:* (8003 is an arbitrary port number to connect to the service listening on 3003. You are free to choose a different one.) 
```
kubectl -n codescene port-forward $(kubectl -n codescene get pod -l app=codescene -o jsonpath='{.items[0].metadata.name}') 8003:3003
```
```
http://localhost:8003
```
If you are using Nginx or Traefik as an ingress controller (i.e. not Istio) then you will need to create an ingress to access from outside. See https://kubernetes.io/docs/concepts/services-networking/ingress/

Here is an example (bog standard ingress defintion)
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: codescene
spec:
  rules:
    - http:
        paths:
          - path: /
            backend:
              serviceName: codescene
              servicePort: 3003
```
Replace the annotation 

`kubernetes.io/ingress.class: nginx` 

with your preferred controller e.g. 

`kubernetes.io/ingress.class: istio`

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
└── tools
    └── check_istio.sh
    └── debug_istio.sh
```
