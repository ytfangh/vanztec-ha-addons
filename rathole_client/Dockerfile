ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG RATHOLE_TAG=rathole-v0.5.0
ARG RATHOLE_OWNER=ytfangh
ARG RATHOLE_REPO=rathole-binaries

RUN set -eux; \
    apk add --no-cache curl ca-certificates; \
    case "${BUILD_ARCH}" in \
      amd64)  BIN="rathole-amd64" ;; \
      aarch64) BIN="rathole-aarch64" ;; \
      armv7)  BIN="rathole-armv7" ;; \
      *) echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}" && exit 1 ;; \
    esac; \
    URL="https://github.com/${RATHOLE_OWNER}/${RATHOLE_REPO}/releases/download/${RATHOLE_TAG}/${BIN}"; \
    curl -fSL --retry 10 --retry-delay 2 --connect-timeout 10 --max-time 180 \
      -o /usr/local/bin/rathole "$URL"; \
    chmod +x /usr/local/bin/rathole; \
    /usr/local/bin/rathole --version || true

# 让 s6 发现服务脚本
COPY rootfs/ /

RUN chmod +x /etc/services.d/rathole/run
