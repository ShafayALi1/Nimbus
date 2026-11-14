# Runbook: pod in CrashLoopBackOff / Pending / ImagePullBackOff

| Status | First command | Usual cause |
|---|---|---|
| CrashLoopBackOff | `kubectl logs <pod> --previous` | bad config/env, dependency missing at start, liveness probe too strict |
| OOMKilled | `kubectl describe pod <pod>` (Last State) | memory limit too low, or a leak: raise the limit in values, then find the leak |
| Pending | `kubectl describe pod <pod>` (Events) | not enough CPU/memory on nodes, PVC not bound, node selector/taint |
| ImagePullBackOff | `kubectl describe pod <pod>` | tag not pushed to localhost:5001, typo in the tag, registry not running |
| CreateContainerConfigError | `kubectl describe pod <pod>` | missing Secret (`nimbus-db`): run `scripts/up.sh` again |
| Blocked at creation | `kubectl get events -n nimbus-dev` | a Kyverno policy said no; the message says which rule |
