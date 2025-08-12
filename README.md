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
