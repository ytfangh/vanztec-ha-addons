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

# 这些探测不要影响启动
bashio::log.info "rathole version: $(/usr/local/bin/rathole --version 2>&1 || true)"
bashio::log.info "rathole help: $(/usr/local/bin/rathole -h 2>&1 | head -n 5 | tr '\n' ' ' || true)"

# 打开 debug 输出
export RUST_LOG=debug
export RUST_BACKTRACE=1

bashio::log.info "Launching rathole with debug logging..."
exec /usr/local/bin/rathole /tmp/client.toml
