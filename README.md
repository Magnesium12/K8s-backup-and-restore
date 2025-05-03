# Kubernetes Backup and Restore System

_Group-4_

## Setup

### 1. Start Kubernetes Cluster
#### Install Minikube
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Also install kubectl:
sudo apt-get update
sudo apt-get install -y kubectl
```
Then start cluster with `minikube start`

### 2. Velero Installation
```bash
curl -LO https://github.com/vmware-tanzu/velero/releases/download/VERSION/velero-VERSION-linux-amd64.tar.gz

tar zxvf velero-VERSION-linuxamd64.tar.gz

sudo mv velero-VERSION-linux-amd64/velero /usr/local/bin/velero

velero version
```

### 3. Create S3 Bucket
Create an S3 bucket on AWS and put its credentials into a file:
```bash
cat > credentials-velero <<EOF
[default]
aws_access_key_id=<ACCESS_KEY_ID>
aws_secret_access_key=<SECRET_ACCESS_KEY>
region=<REGION>
EOF
```

### 4. Connect Velero to S3 bucket
```bash
velero install \
   --provider aws \
   --plugins velero/velero-plugin-for-aws:v1.6.0 \
   --bucket <S3_BUCKET> \
   --secret-file ./credentials-velero \
   --backup-location-config region=<REGION> \
   --use-volume-snapshots=false
```
Verify with `velero backup-location get`

### 5. Deployment
```bash
# Create Namespace
kubectl create ns nginx-demo

# Create Deployment
kubectl create deployment nginx --image=nginx -n nginx-demo

# Expose deployment to a service
kubectl expose deployment nginx --name=nginxsrv --port=80 --type=NodePort -n nginx-demo

# Port forwarding
kubectl port-forward svc/nginxsrv 8000:80 -n nginx-demo
```
nginx service should be up at `127.0.0.1:8000`.

## Backup creation
```bash
velero backup create nginx-backup --include-namespaces nginx-demo

# Check backup status
velero backup describe nginx-backup --details
```
Backup should be visible on AWS S3 bucket.

List all backups by `velero backup get`.

## Simulate a disaster
```bash
kubectl delete ns nginx-demo

kubectl get all -n nginx-demo   #Should be empty
```
nginx deployment should be down now. Verify by visiting `127.0.0.1:8000`.

## Restoration
```bash
velero restore create --from-backup nginx-backup

kubectl get all -n nginx-demo   #Should contain the deployment
```
Restore file can also be seen on AWS S3 bucket.

## Scheduling backups
```bash
velero schedule create nginx-backup-schedule \
  --schedule "0 */6 * * *" \
  --include-namespaces nginx-demo \
  --ttl 72h0m0s
```
