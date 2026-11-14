#!/usr/bin/env bash
# Get a free public HTTPS URL for Nimbus (open it on your phone). No account needed: Cloudflare quick tunnel.
# The URL changes every time. Stop it with: kubectl -n traefik delete pod tunnel
set -euo pipefail
kubectl -n traefik delete pod tunnel --ignore-not-found >/dev/null
kubectl -n traefik run tunnel --image=cloudflare/cloudflared:2025.1.0 --restart=Never -- \
  tunnel --no-autoupdate --url http://traefik.traefik.svc:80 --http-host-header nimbus.localtest.me
echo "Waiting for the URL..."
for i in $(seq 1 30); do
  url=$(kubectl -n traefik logs tunnel 2>/dev/null | grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' | head -1 || true)
  [ -n "$url" ] && { echo "Public URL: $url"; exit 0; }
  sleep 2
done
echo "No URL yet; check: kubectl -n traefik logs tunnel"; exit 1
