#!/bin/bash

aws-iam-authenticator init -i $ekscluster
aws eks update-kubeconfig --name $ekscluster --r $eksregion

kubectl delete secrets regcred || true
docker login -u $USERNAME -p $PASSWORD docker.io
kubectl create secret docker-registry regcred --docker-server=$dockerrepo --docker-username=$USERNAME --docker-password=$PASSWORD --docker-email=$dockeremail || true

cd

echo '
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: $eksnoderole
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: $eksadminrole
      username: admin
      groups:
        - system:masters' > aws-auth-cm.yaml

kubectl apply -f aws-auth-cm.yaml
kubectl --namespace kube-system create serviceaccount tiller || true
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller || true
/usr/local/bin/helm init --service-account tiller || true
/usr/local/bin/helm init --upgrade --service-account tiller || true
kubectl patch deployment tiller-deploy --namespace=kube-system --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]' || true