#!/usr/bin/env bash
# Experiment 2: queue 50 orders, kill every worker at once (no grace period). Expect: all 50 processed anyway.
set -euo pipefail
NS=${NS:-nimbus-dev}
for i in $(seq 1 50); do curl -s -o /dev/null -X POST -d "item=chaos-$i&quantity=1" http://nimbus.localtest.me:8088/order; done
echo "50 orders queued; killing all workers with no grace period"
kubectl -n $NS delete pods -l app.kubernetes.io/name=worker --grace-period=0 --force
echo "Now watch: pending should drop to 0 within ~2 minutes (reconciler re-queues lost jobs)"
for i in $(seq 1 24); do
  pending=$(kubectl -n $NS exec statefulset/postgres -- psql -U nimbus -tAc "select count(*) from orders where status='pending'")
  echo "pending orders: $pending"; [ "$pending" = "0" ] && exit 0; sleep 10
done
exit 1
