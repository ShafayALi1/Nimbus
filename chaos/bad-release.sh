#!/usr/bin/env bash
# Experiment 6: ship a release where 50% of orders-api requests fail, through Git like any release.
# Expect: canary gets 25% of pods, analysis sees errors, Argo Rollouts aborts and rolls back by itself.
set -euo pipefail
cd "$(dirname "$0")/.."
sed -i '/CHAOS_ERROR_RATE/{n;s/value: "0"/value: "0.5"/}' gitops/envs/dev/orders-api.yaml
git commit -am "chaos: bad release (orders-api fails 50%)" && git push
echo "Start traffic now: bash scripts/load.sh 300"
echo "Watch:            kubectl argo rollouts get rollout orders-api -n nimbus-dev --watch"
echo "Undo afterwards:  git revert --no-edit HEAD && git push"
