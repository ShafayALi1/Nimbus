# 5. One Helm chart for every service

**Decision:** `helm/nimbus-service` serves web, orders-api and worker; differences live in small values files.
**Why:** security context, probes, PDB, network policy and spread constraints are written once and enforced everywhere. A new service is a 20-line values file.
**Trade-off:** the chart must stay generic (probes and env are overridable lists), so it's slightly harder to read than three hand-written manifests.
