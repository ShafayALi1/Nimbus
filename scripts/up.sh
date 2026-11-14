#!/usr/bin/env bash
# Build the whole Nimbus platform on your laptop, free. Run in WSL Ubuntu from the nimbus-platform folder.
#   bash scripts/up.sh
# Safe to run again: every step checks first. Takes ~10 minutes the first time (image downloads).
set -euo pipefail
cd "$(dirname "$0")/.."

CLUSTER=nimbus
REGISTRY=kind-registry
REG_PORT=5001
NIMBUS_APP=${NIMBUS_APP:-../nimbus-app}
ARGOCD_CHART_VERSION=10.18.0
ENVIRONMENTS=${ENVIRONMENTS:-dev}          # "dev prod" for both

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
for tool in docker kind kubectl helm git openssl; do
  command -v "$tool" >/dev/null || { echo "missing: $tool (run scripts/install-tools.sh)"; exit 1; }
done

# Argo CD reads this repo from GitHub. Use your remote, as https.
REPO_URL=${REPO_URL:-$(git remote get-url origin 2>/dev/null || true)}
REPO_URL=$(echo "$REPO_URL" | sed -E 's#^git@github.com:#https://github.com/#; s#^https://[^@/]+@#https://#')   # drop any user@ part
[ -n "$REPO_URL" ] || { echo "Push nimbus-platform to GitHub first (git remote add origin ...), or set REPO_URL"; exit 1; }

step "Local image registry on localhost:$REG_PORT"
if [ "$(docker inspect -f '{{.State.Running}}' $REGISTRY 2>/dev/null || true)" != "true" ]; then
  docker run -d --restart=always -p "127.0.0.1:$REG_PORT:5000" --name $REGISTRY registry:2
fi

step "kind cluster '$CLUSTER' (1 control plane + 2 workers)"
kind get clusters | grep -qx $CLUSTER || kind create cluster --config kind/cluster.yaml

step "Let the nodes pull from the local registry"
for node in $(kind get nodes --name $CLUSTER); do
  docker exec "$node" mkdir -p "/etc/containerd/certs.d/localhost:$REG_PORT"
  printf '[host."http://%s:5000"]\n' $REGISTRY | docker exec -i "$node" cp /dev/stdin "/etc/containerd/certs.d/localhost:$REG_PORT/hosts.toml"
done
docker network connect kind $REGISTRY 2>/dev/null || true
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata: { name: local-registry-hosting, namespace: kube-public }
data:
  localRegistryHosting.v1: |
    host: "localhost:$REG_PORT"
EOF

step "Build and push the image tags that Git says are deployed"
for svc in web orders-api worker; do
  tag=$(grep -m1 '^  tag:' gitops/envs/dev/$svc.yaml | cut -d'"' -f2)
  image=localhost:$REG_PORT/nimbus/$svc:$tag
  if ! docker manifest inspect --insecure "$image" >/dev/null 2>&1; then
    docker build -t "$image" "$NIMBUS_APP/services/$svc"
    docker push "$image"
  fi
done

step "Secrets (generated here, never stored in Git)"
for env in $ENVIRONMENTS; do
  kubectl create namespace nimbus-$env --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n nimbus-$env get secret nimbus-db >/dev/null 2>&1 ||
    kubectl -n nimbus-$env create secret generic nimbus-db --from-literal=password="$(openssl rand -hex 16)"
done
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl -n monitoring get secret grafana-admin >/dev/null 2>&1 ||
  kubectl -n monitoring create secret generic grafana-admin \
    --from-literal=admin-user=admin --from-literal=admin-password="$(openssl rand -hex 12)"

step "Argo CD"
if helm -n argocd status argocd >/dev/null 2>&1; then
  echo "already installed"
else
  helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
  helm repo update argo || echo "chart index update failed; using the cached copy"
  helm upgrade --install argocd argo/argo-cd --version $ARGOCD_CHART_VERSION \
    -n argocd --create-namespace -f platform/argocd-values.yaml --wait --timeout 10m
fi

step "Root application: Argo CD now installs everything else from Git ($REPO_URL)"
envs_yaml=$(printf '"%s",' $ENVIRONMENTS); envs_yaml="[${envs_yaml%,}]"
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  destination: { server: https://kubernetes.default.svc, namespace: argocd }
  source:
    repoURL: $REPO_URL
    targetRevision: main
    path: gitops/root
    helm:
      valuesObject:
        repoURL: $REPO_URL
        environments: $envs_yaml
  syncPolicy:
    automated: { prune: true, selfHeal: true }
EOF

step "Waiting for the apps (first time: ~5-10 min while images download)"
expected=$(( 10 + 4 * $(echo $ENVIRONMENTS | wc -w) ))   # root + 6 charts + 3 folders + 4 per environment
for i in $(seq 1 60); do
  apps=$(kubectl -n argocd get applications -o jsonpath='{range .items[*]}{.status.health.status}{"\n"}{end}' 2>/dev/null || true)
  healthy=$(echo "$apps" | grep -c '^Healthy$' || true)
  printf '\r  %s/%s applications healthy ' "$healthy" "$expected"
  [ "$healthy" -ge "$expected" ] && break
  sleep 15
done
echo; kubectl -n argocd get applications

cat <<EOF

Nimbus is up.
  App:      http://nimbus.localtest.me:8088
  Argo CD:  http://argocd.localtest.me:8088   user admin, password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
  Grafana:  http://grafana.localtest.me:8088  user admin, password: $(kubectl -n monitoring get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d)
  Prometheus: kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090
  Canary:   kubectl argo rollouts get rollout orders-api -n nimbus-dev --watch
Stop everything: bash scripts/down.sh   (start again: bash scripts/up.sh)
EOF
