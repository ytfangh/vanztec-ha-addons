ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG RATHOLE_TAG
ARG RATHOLE_OWNER
ARG RATHOLE_REPO

RUN set -eux; \
    echo "BUILD_FROM=${BUILD_FROM}"; \
    echo "BUILD_ARCH=${BUILD_ARCH}"; \
    \
    # ---- install deps (apk or apt) ---- \
    if command -v apk >/dev/null 2>&1; then \
      apk add --no-cache curl ca-certificates unzip; \
    elif command -v apt-get >/dev/null 2>&1; then \
      apt-get update; \
      apt-get install -y --no-install-recommends curl ca-certificates unzip; \
      rm -rf /var/lib/apt/lists/*; \
    else \
      echo "ERROR: no supported package manager (apk/apt-get)"; \
      exit 1; \
    fi; \
    \
    # ---- map HA BUILD_ARCH to official asset name ---- \
    case "${BUILD_ARCH}" in \
      amd64)   ASSET="rathole-x86_64-unknown-linux-gnu.zip" ;; \
      aarch64) ASSET="rathole-aarch64-unknown-linux-musl.zip" ;; \
      *) echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}" && exit 1 ;; \
    esac; \
    \
    URL="https://github.com/${RATHOLE_OWNER}/${RATHOLE_REPO}/releases/download/${RATHOLE_TAG}/${ASSET}"; \
    echo "Downloading: ${URL}"; \
    curl -fSL --retry 10 --retry-delay 2 --connect-timeout 10 --max-time 180 -o /tmp/rathole.zip "${URL}"; \
    unzip -o /tmp/rathole.zip -d /usr/local/bin/; \
    rm -f /tmp/rathole.zip; \
    chmod +x /usr/local/bin/rathole; \
    /usr/local/bin/rathole --version || true

COPY rootfs/ /
RUN chmod +x /usr/bin/start.sh
ENTRYPOINT ["/usr/bin/start.sh"]
