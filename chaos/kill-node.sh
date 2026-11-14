#!/usr/bin/env bash
# Experiment 3: stop a worker node (it's a Docker container). Expect: the app keeps answering;
# after ~5 min Kubernetes moves the lost pods. Then the node comes back.
set -euo pipefail
node=${1:-nimbus-worker}
echo "stopping node $node"; docker stop "$node"
kubectl get nodes; echo "watch: kubectl get pods -A -o wide -w   (Ctrl+C when done)"
read -rp "Press Enter to start the node again... " _
docker start "$node"; kubectl get nodes
