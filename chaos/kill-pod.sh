#!/usr/bin/env bash
# Experiment 1: delete one orders-api pod. Expect: no failed orders, a new pod within seconds.
set -euo pipefail
NS=${NS:-nimbus-dev}
pod=$(kubectl -n $NS get pods -l app.kubernetes.io/name=orders-api -o name | shuf -n1)
echo "deleting $pod"; kubectl -n $NS delete "$pod" --wait=false
kubectl -n $NS get pods -l app.kubernetes.io/name=orders-api -w --request-timeout=30s || true
