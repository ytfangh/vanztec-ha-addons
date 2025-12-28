#!/usr/bin/env bash
set -e

source /usr/lib/bashio/bashio.sh

VPS_HOST="$(bashio::config 'vps_host')"
VPS_PORT="$(bashio::config 'vps_port')"
CLIENT_ID="$(bashio::config 'client_id')"
TOKEN="$(bashio::config 'token')"
HA_LOCAL="$(bashio::config 'ha_local')"

cat > /tmp/client.toml <<EOF
[client]
remote_addr = "${VPS_HOST}:${VPS_PORT}"

[client.services.${CLIENT_ID}]
token = "${TOKEN}"
local_addr = "${HA_LOCAL}"
EOF

bashio::log.info "Starting rathole client_id=${CLIENT_ID}"
bashio::log.info "Launching: rathole client /tmp/client.toml"
bashio::log.info "rathole version: $(/usr/local/bin/rathole --version 2>&1 || true)"
bashio::log.info "rathole help: $(/usr/local/bin/rathole --help 2>&1 | head -n 5)"
exec /usr/local/bin/rathole client /tmp/client.toml
