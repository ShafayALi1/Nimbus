#!/usr/bin/env bash
# Delete the cluster (all data in it is gone). Keep the registry so images don't need rebuilding.
#   bash scripts/down.sh          bash scripts/down.sh --all   (also remove the registry)
set -euo pipefail
kind delete cluster --name nimbus
[ "${1:-}" = "--all" ] && docker rm -f kind-registry || true
