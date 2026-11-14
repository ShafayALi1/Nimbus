# Runbook: queue backlog / worker not processing

**Alerts:** `WorkerQueueBacklog` (over 100 waiting for 10 min), `WorkerNotProcessing` (jobs waiting, none processed).

1. Workers running? `kubectl -n nimbus-dev get pods -l app.kubernetes.io/name=worker`. CrashLoopBackOff → `kubectl logs --previous`.
2. Workers alive but stuck? The logs repeat `dependency error` → PostgreSQL or Redis is down; fix that first.
3. Just too much work? Scale: `replicas` in `gitops/envs/dev/worker.yaml` (commit and push). For an emergency, `kubectl scale`, but Argo CD will undo it, so commit too.
4. Jobs failing? `select status, count(*) from orders group by status;` (exec into the postgres pod with `psql -U nimbus`). Many `failed` → read the worker errors in Loki.
