# Runbook: orders-api error budget burning

**Alert:** `OrdersApiErrorBudgetFastBurn` (critical) / `SlowBurn` (warning). More than 0.5% of `/orders` requests fail.

1. **Was there a release?** `kubectl argo rollouts get rollout orders-api -n nimbus-dev`. If a canary is running: `kubectl argo rollouts abort orders-api -n nimbus-dev`, then `git revert` the tag commit in nimbus-platform.
2. **Is it a dependency?** `kubectl -n nimbus-dev exec deploy/web -- python -c "import urllib.request as u; print(u.urlopen('http://orders-api:8000/readyz').read())"` shows database and redis status. Not ready → go to the PostgreSQL or Redis runbook.
3. **What do the logs say?** Grafana → Explore → Loki: `{namespace="nimbus-dev", app="orders-api"} |= "error"`.
4. **Chaos left on?** `grep -A1 CHAOS gitops/envs/dev/orders-api.yaml`. It must be `"0"`.
5. Resolved when the 5-minute error ratio is back under 0.5%. Write a postmortem if users were affected.
