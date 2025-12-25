ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH

RUN apk add --no-cache bash curl ca-certificates

# Download rathole v0.5.0 binary for the correct architecture
RUN set -eux; \
    case "${BUILD_ARCH}" in \
      amd64)  R_ARCH="x86_64-unknown-linux-musl" ;; \
      aarch64) R_ARCH="aarch64-unknown-linux-musl" ;; \
      armv7)  R_ARCH="armv7-unknown-linux-musleabihf" ;; \
      *) echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}" && exit 1 ;; \
    esac; \
    curl -L -o /tmp/rathole.tar.gz "https://github.com/rapiz1/rathole/releases/download/v0.5.0/rathole-${R_ARCH}.tar.gz"; \
    tar -xzf /tmp/rathole.tar.gz -C /usr/local/bin rathole; \
    chmod +x /usr/local/bin/rathole; \
    rm -f /tmp/rathole.tar.gz

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
