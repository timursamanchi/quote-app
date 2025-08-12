# quote-app
quote-app using kubernetes, helm, docker (jekyll, nginx, redis) and terraform for AWS deployment


# 1) Start Minikube (Docker driver is fine on macOS)
minikube start --driver=docker

# (optional) you can do it all-in-one:
# minikube start --driver=docker --addons=ingress,metrics-server

# 2) Enable addons (if you didn’t use --addons)
minikube addons enable ingress
minikube addons enable metrics-server

# 3) Verify they’re up
kubectl get pods -n ingress-nginx
kubectl -n kube-system get deploy metrics-server

# 4) Test metrics
kubectl top nodes
kubectl top pods -A



If you want to see it actually scale, throw some load:

# quick n’ dirty load in-cluster
kubectl -n quote-app run loadgen --image=busybox --restart=Never -- sh -c \
  'while true; do wget -q -O- http://quote-app-backend:8080 >/dev/null; done'

Watch it:

kubectl -n quote-app get hpa -w
kubectl -n quote-app top pods
kubectl -n quote-app get deploy quote-app-backend -w

Clean up the loader when done:

kubectl -n quote-app delete pod loadgen --force --grace-period=0


Quick sanity flow next:

# 1) Validate with kubectl (no changes to cluster)
helm template quote-app . -n quote-app --values values.yaml \
| kubectl apply --dry-run=client -f -

# 2) Dry-run install with Helm debug
helm install quote-app . -n quote-app --create-namespace \
  --values values.yaml --dry-run --debug

Optional quick checks:

# Test adding a storage class
helm template quote-app . -n quote-app --set pvc.storageClassName=standard

# Test renaming the PVC
helm template quote-app . -n quote-app --set pvc.name=redis-data-prod

If that all looks good, ship it:

helm upgrade --install quote-app . -n quote-app --create-namespace --values values.yaml
