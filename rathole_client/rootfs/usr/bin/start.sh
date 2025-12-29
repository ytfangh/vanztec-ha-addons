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
bashio::log.info "client.toml: $(cat /tmp/client.toml | tr '\n' ' ')"

bashio::log.info "rathole version: $(/usr/local/bin/rathole --version 2>&1 || true)"
bashio::log.info "rathole help: $(/usr/local/bin/rathole -h 2>&1 | head -n 5 | tr '\n' ' ' || true)"

bashio::log.info "Launching rathole with debug logging..."
export RUST_LOG=debug
export RUST_BACKTRACE=1

bashio::log.info "rathole file info:"
ls -l /usr/local/bin/rathole || true

bashio::log.info "arch: $(uname -m)"
bashio::log.info "trying to run rathole..."
/usr/local/bin/rathole --version 2>&1 || true

bashio::log.info "ldd check:"
ldd /usr/local/bin/rathole 2>&1 || true

bashio::log.info "now exec rathole..."
exec /usr/local/bin/rathole /tmp/client.toml 2>&1

