# Chaos experiments

Each script breaks one thing on purpose. Before each one, write down what you **expect** to happen.
Run `bash scripts/load.sh 180` in a second terminal so there is real traffic, and watch Grafana.
Afterwards write a postmortem from `docs/postmortems/TEMPLATE.md`, even when nothing broke.

| # | Script | What breaks | What should save you |
|---|---|---|---|
| 1 | `kill-pod.sh` | one orders-api pod dies | 2+ replicas, readiness probes, PDB |
| 2 | `kill-worker-mid-job.sh` | a worker dies while jobs are queued | SIGTERM handling, idempotent jobs, reconciler |
| 3 | `kill-node.sh` | a whole node goes away | topology spread, replicas on other nodes |
| 4 | `break-dns.sh` | CoreDNS is gone for 60 s | timeouts, retries, web's "unavailable" banner |
| 5 | `fill-disk.sh` | a worker fills its /tmp | emptyDir sizeLimit → kubelet evicts and replaces the pod |
| 6 | `bad-release.sh` | a release that fails 50% of requests | canary analysis rolls back automatically |
