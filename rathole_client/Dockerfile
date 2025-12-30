ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG RATHOLE_TAG
ARG RATHOLE_OWNER
ARG RATHOLE_REPO

ARG VT_TEST_ARG
RUN echo "VT_TEST_ARG=${VT_TEST_ARG:-<unset>}"

RUN set -eux; \
    echo "BUILD_FROM=${BUILD_FROM:-<unset>}"; \
    echo "BUILD_ARCH=${BUILD_ARCH:-<unset>}"; \
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
    # 原始 URL（基于参数）
    URL="https://github.com/${RATHOLE_OWNER}/${RATHOLE_REPO}/releases/download/${RATHOLE_TAG}/${ASSET}"; \
    echo "Attempting download from: ${URL}"; \
    
    # 添加调试信息：先尝试 HEAD 请求检查可用性
    echo "Checking URL availability..."; \
    if curl -f -I "${URL}" 2>/dev/null | grep -q "301\|302\|Location"; then \
        echo "INFO: URL redirects, curl will follow with -L flag"; \
    fi; \
    
    # 下载并自动跟随重定向
    curl -fL --retry 10 --retry-delay 2 --connect-timeout 10 --max-time 180 -o /tmp/rathole.zip "${URL}" || \
        { echo "ERROR: Failed to download from ${URL}"; exit 1; }; \
    \
    # ---- extract safely, then install the 'rathole' binary ---- \
    mkdir -p /tmp/rathole_ex; \
    unzip -o /tmp/rathole.zip -d /tmp/rathole_ex; \
    rm -f /tmp/rathole.zip; \
    \
    # find the binary named 'rathole' in the extracted contents
    RATHOLE_BIN="$(find /tmp/rathole_ex -type f -name rathole -maxdepth 3 | head -n 1)"; \
    if [ -z "${RATHOLE_BIN}" ]; then \
      echo "ERROR: cannot find 'rathole' binary in release asset ${ASSET}"; \
      echo "Extracted files:"; \
      find /tmp/rathole_ex -maxdepth 3 -type f -print; \
      exit 1; \
    fi; \
    install -m 0755 "${RATHOLE_BIN}" /usr/local/bin/rathole; \
    rm -rf /tmp/rathole_ex; \
    \
    /usr/local/bin/rathole --version || true

COPY rootfs/ /
RUN chmod +x /usr/bin/start.sh
ENTRYPOINT ["/usr/bin/start.sh"]
