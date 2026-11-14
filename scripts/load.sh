#!/usr/bin/env bash
# Send orders through the real path (ingress -> web -> orders-api -> queue -> worker) and count outcomes.
#   bash scripts/load.sh [seconds] [url]        default: 120 s against http://nimbus.localtest.me:8088
set -uo pipefail
SECONDS_TO_RUN=${1:-120}; URL=${2:-http://nimbus.localtest.me:8088}
ok=0; failed=0; end=$(( $(date +%s) + SECONDS_TO_RUN ))
while [ "$(date +%s)" -lt "$end" ]; do
  loc=$(curl -s -o /dev/null -m 5 -w '%{redirect_url}' -X POST -d "item=load-test&quantity=1" "$URL/order")
  case "$loc" in *created=*) ok=$((ok+1));; *) failed=$((failed+1));; esac
  printf '\r  ok=%d failed=%d ' "$ok" "$failed"
  sleep 0.2
done
echo; echo "success rate: $(( 100 * ok / (ok + failed > 0 ? ok + failed : 1) ))%"
