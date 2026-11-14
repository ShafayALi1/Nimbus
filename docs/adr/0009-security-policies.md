# 9. Security enforced by policy, not by memory

**Decision:** Kyverno blocks pods in `nimbus-*` namespaces that run as root, use `:latest`, lack resource limits or have a writable root filesystem. Network policies allow only the needed connections. Secrets are generated in-cluster and never committed.
**Why:** a rule that a machine checks on every deploy beats a checklist. Proof: `kubectl -n nimbus-dev run bad --image=nginx:latest` is refused with the reasons.
**Trade-off:** third-party images often need extra settings (UIDs, writable volumes) to pass. The registry policy starts in Audit mode for that reason.
