# quote-app

A tiny 3-tier demo app running on Kubernetes with Helm and Docker:

    Frontend: Jekyll + NGINX

    Backend: Flask (serves /quote)

    Database: Redis (with PVC)

Includes HPAs, Ingress, and is EKS-ready later via Terraform.
Prerequisites

    Docker

    kubectl

    Helm

    Minikube (for local testing)

## Quick start (Minikube)
1) Start Minikube

### Simple
minikube start --driver=docker

### Or all-in-one with addons enabled
### minikube start --driver=docker --addons=ingress,metrics-server

## 2) Enable addons (if you didn’t use --addons)

minikube addons enable ingress
minikube addons enable metrics-server

## 3) Verify addons

kubectl get pods -n ingress-nginx
kubectl -n kube-system get deploy metrics-server
kubectl top nodes
kubectl top pods -A

## 4) Install / upgrade the chart

helm upgrade --install quote-app . -n quote-app --create-namespace

Access the app (Ingress)

IP=$(minikube ip)
curl -i http://$IP/        # frontend
curl -i http://$IP/quote   # backend via ingress

Sanity checks

Overview

helm -n quote-app status quote-app
kubectl -n quote-app get deploy,po,svc,endpoints,ingress,hpa,pvc

Rollouts

kubectl -n quote-app rollout status deploy/quote-backend
kubectl -n quote-app rollout status deploy/quote-redis

Services wired to Pods

kubectl -n quote-app get ep quote-backend -o wide
kubectl -n quote-app get ep quote-redis   -o wide
## If endpoints are <none>, it’s a label selector mismatch.

HTTP check to backend

## Local port-forward
kubectl -n quote-app port-forward svc/quote-backend 8080:8080 >/tmp/pf.log 2>&1 &
PF=$!; sleep 1
curl -fsS http://localhost:8080/quote | head -n1
kill $PF

Logs

kubectl -n quote-app logs deploy/quote-backend --tail=100
kubectl -n quote-app logs deploy/quote-redis   --tail=50

PVC

kubectl -n quote-app get pvc
kubectl -n quote-app describe pvc redis-data

Events (last 30)

kubectl -n quote-app get events --sort-by=.lastTimestamp | tail -n 30

Autoscaling demo (HPA)

Generate load (in-cluster)

kubectl -n quote-app run loadgen --image=busybox --restart=Never -- \
  sh -c 'while true; do wget -q -O- http://quote-backend:8080/quote >/dev/null; done'

Watch scaling

kubectl -n quote-app get hpa -w
kubectl -n quote-app top pods
kubectl -n quote-app get deploy quote-backend -w

Clean up the loader

kubectl -n quote-app delete pod loadgen --force --grace-period=0

Dry runs / validation

Validate rendered manifests with kubectl (no changes to cluster)

helm template quote-app . -n quote-app --values values.yaml \
| kubectl apply --dry-run=client -f -

Helm dry-run with debug

helm install quote-app . -n quote-app --create-namespace \
  --values values.yaml --dry-run --debug

Optional render tests

## Test setting a storage class
helm template quote-app . -n quote-app --set pvc.storageClassName=standard

## Test renaming the PVC
helm template quote-app . -n quote-app --set pvc.name=redis-data-prod

Cleanup

helm uninstall quote-app -n quote-app

## If a PV remains due to Retain policy:
kubectl get pv | grep redis || true
kubectl delete pvc redis-data -n quote-app || true

Notes

    If port-forward fails, check /tmp/pf.log and ensure local port 8080 isn’t in use (lsof -nP -iTCP:8080 -sTCP:LISTEN).

    Ingress host/TLS can be added later via values (e.g., ingress.host, ingress.tls.enabled, ingress.tls.secretName).

END