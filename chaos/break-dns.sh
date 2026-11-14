#!/usr/bin/env bash
# Experiment 4: remove cluster DNS for 60 s. Expect: web shows "unavailable" instead of hanging; full recovery after.
set -euo pipefail
kubectl -n kube-system scale deployment coredns --replicas=0
echo "DNS is down. Open http://nimbus.localtest.me:8088 now."; sleep 60
kubectl -n kube-system scale deployment coredns --replicas=2
kubectl -n kube-system rollout status deployment coredns
