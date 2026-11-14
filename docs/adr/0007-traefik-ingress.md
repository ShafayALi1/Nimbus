# 7. Traefik as ingress controller

**Decision:** Traefik, with ports 80/443 on the kind control-plane node mapped to localhost:8080/8443; hostnames under `localtest.me`.
**Why:** ingress-nginx was retired in March 2026 (no more fixes). Traefik supports standard Ingress and Gateway API, so a later move to Gateway API is small.
**Trade-off:** annotations differ from the nginx examples found online.
