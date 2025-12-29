ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG RATHOLE_TAG=rathole-v0.5.0
ARG RATHOLE_OWNER=ytfangh
ARG RATHOLE_REPO=rathole-binaries

RUN set -eux; \
    echo "=== Build info ==="; \
    echo "BUILD_FROM=${BUILD_FROM}"; \
    echo "BUILD_ARCH=${BUILD_ARCH}"; \
    if command -v ldd >/dev/null 2>&1; then \
      echo -n "ldd: "; ldd --version 2>&1 | head -n 1 || true; \
      if ldd --version 2>&1 | grep -qi musl; then echo "LIBC=musl"; else echo "LIBC=glibc"; fi; \
    else \
      echo "ldd: not found"; \
    fi; \
    echo "uname -m: $(uname -m)"; \
    echo "=================="; \
    apk add --no-cache curl ca-certificates; \
    case "${BUILD_ARCH}" in \
      amd64)   BIN="rathole-amd64" ;; \
      aarch64) BIN="rathole-aarch64" ;; \
      armv7)   BIN="rathole-armv7" ;; \
      *) echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}" && exit 1 ;; \
    esac; \
    URL="https://github.com/${RATHOLE_OWNER}/${RATHOLE_REPO}/releases/download/${RATHOLE_TAG}/${BIN}"; \
    echo "Downloading: ${URL}"; \
    curl -fSL --retry 10 --retry-delay 2 --connect-timeout 10 --max-time 180 \
      -o /usr/local/bin/rathole "$URL"; \
    chmod +x /usr/local/bin/rathole; \
    /usr/local/bin/rathole --version || true

COPY rootfs/ /
RUN chmod +x /usr/bin/start.sh
ENTRYPOINT ["/usr/bin/start.sh"]
