#!/bin/bash

# Array of comments
comments=(
  "Installing velero into cluster"
  "Creating namespace"
  "Creating deployment"
  "Exposing deployment to a service"
  "Backup creation"
  "Backup details"
  "Simulating disaster"
  "Restoration"
  "Restored cluster"
)

# Array of multiline commands
commands=(
  "velero install \
   --provider aws \
   --plugins velero/velero-plugin-for-aws:v1.6.0 \
   --bucket k8s-cluster-backups-velero-hrishit \
   --secret-file ./credentials-velero \
   --backup-location-config region=eu-north-1 \
   --use-volume-snapshots=false"
  "kubectl create ns nginx-demo"
  "kubectl create deployment nginx --image=nginx -n nginx-demo"
  "kubectl expose deployment nginx --name=nginxsrv --port=80 --type=NodePort -n nginx-demo"
  "velero backup create nginx-backup --include-namespaces nginx-demo"
  "velero backup describe nginx-backup --details"
  "kubectl delete ns nginx-demo && kubectl get all -n nginx-demo"
  "velero restore create --from-backup nginx-backup"
  "kubectl get all -n nginx-demo"
)

# Execute each command on keypress
for i in "${!commands[@]}"; do
  echo
  echo "# ${comments[$i]}"
  read -p "Press Enter to run:"
  eval "${commands[$i]}"
done
