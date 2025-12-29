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

# --------------------------------------------------
# Detect arch
# --------------------------------------------------
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64)  ARCH="x86_64" ;;
  aarch64) ARCH="aarch64" ;;
  *)
    bashio::log.error "Unsupported CPU architecture: ${ARCH_RAW}. This add-on supports amd64(x86_64) and aarch64(arm64) only."
    exit 1
    ;;
esac

# --------------------------------------------------
# Detect libc (glibc vs musl)
# --------------------------------------------------
if command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -qi musl; then
  LIBC="musl"
else
  LIBC="glibc"
fi

bashio::log.info "System arch detected: ${ARCH}"
bashio::log.info "System libc detected: ${LIBC}"

# --------------------------------------------------
# Rathole diagnostics
# --------------------------------------------------
bashio::log.info "rathole version: $(/usr/local/bin/rathole --version 2>&1 || true)"
bashio::log.info "rathole help: $(/usr/local/bin/rathole -h 2>&1 | head -n 5 | tr '\n' ' ' || true)"

bashio::log.info "Launching rathole with debug logging..."
export RUST_LOG=debug
export RUST_BACKTRACE=1

bashio::log.info "rathole file info:"
ls -l /usr/local/bin/rathole || true

bashio::log.info "uname -m raw: ${ARCH_RAW}"

bashio::log.info "trying to run rathole --version..."
/usr/local/bin/rathole --version 2>&1 || true

bashio::log.info "ldd check:"
ldd /usr/local/bin/rathole 2>&1 || true

# --------------------------------------------------
# Exec rathole
# --------------------------------------------------
bashio::log.info "now exec rathole..."
exec /usr/local/bin/rathole /tmp/client.toml 2>&1
