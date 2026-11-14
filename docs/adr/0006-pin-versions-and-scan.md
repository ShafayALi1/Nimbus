# 6. Pin every version; scan every image

**Decision:** image tags = git SHA (never `latest`); chart, tool and base-image versions pinned; Trivy fails the build on fixable HIGH/CRITICAL CVEs.
**Why:** reproducible builds and exact rollbacks. Real example: in March 2026 attackers force-pushed 76 of 77 `trivy-action` tags and published malicious Trivy 0.69.4–0.69.6 (CVE-2026-33634). Anyone on `latest` or a mutable tag ran a credential stealer. We pin `aquasec/trivy:0.69.3` and run it as an image.
**Trade-off:** upgrades are manual commits (use Renovate/Dependabot later to propose them).
