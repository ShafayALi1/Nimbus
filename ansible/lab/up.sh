#!/bin/sh
# Create an SSH key for the lab (once), build and start the two lab servers, then test the connection.
set -eu
cd "$(dirname "$0")"
[ -f .ssh/id_ed25519 ] || { mkdir -p .ssh && ssh-keygen -q -t ed25519 -N "" -C nimbus-lab -f .ssh/id_ed25519; }
chmod 600 .ssh/id_ed25519
docker compose up -d --build
cd .. && sleep 5 && ansible all -m ping
