# quick n’ dirty load in-cluster
kubectl -n quote-app run loadgen --image=busybox --restart=Never -- sh -c \
  'while true; do wget -q -O- http://quote-app-backend:8080 >/dev/null; done'
