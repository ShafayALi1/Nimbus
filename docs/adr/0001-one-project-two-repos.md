# 1. One project, two repos

**Decision:** `nimbus-app` holds code and CI; `nimbus-platform` holds infrastructure and deploy config.
**Why:** different change rates and owners. CI can bump an image tag in the platform repo without app developers touching cluster config, and the cluster is never given CI's credentials.
**Trade-off:** two repos to keep in step; a release touches both (handled automatically by the CI tag bump).
