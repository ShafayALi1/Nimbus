#!/usr/bin/env bash
# Experiment 5: write 100 MB into a worker's /tmp (limit 64 Mi). Expect: kubelet evicts that pod, a new one starts.
set -euo pipefail
NS=${NS:-nimbus-dev}
pod=$(kubectl -n $NS get pods -l app.kubernetes.io/name=worker -o name | head -1)
kubectl -n $NS exec "$pod" -- python -c "open('/tmp/fill','wb').write(b'0' * 100 * 1024 * 1024)" || true
echo "watch the eviction: kubectl -n $NS get pods -w   and   kubectl -n $NS get events --sort-by=.lastTimestamp | tail"
