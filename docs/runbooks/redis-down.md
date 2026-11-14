# Runbook: Redis down

**Symptoms:** `OrdersNotQueued` alert, orders-api `/readyz` = 503, worker logs `dependency error`.
**Impact:** small. Orders are still saved (status `pending`). When Redis returns, the worker's reconciler queues them again within ~90 s. No data is lost.

1. `kubectl -n nimbus-dev get pod redis-0` and `kubectl -n nimbus-dev logs redis-0`.
2. Out of memory (`OOMKilled`)? Raise `redis.resources.limits.memory` in `gitops/envs/dev/data.yaml`.
3. After recovery: `select count(*) from orders where status='pending';` should fall to 0 within 2 minutes.
