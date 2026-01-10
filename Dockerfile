# Build stage
FROM debian:bookworm-slim AS builder

ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Download and extract GBDK-2020 by TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.5.0/gbdk-linux-arm64.tar.gz"; \
        GBDK_SHA256="31eb2235f0fdb60163d0b1e9574a022098d6069cd56606a1daca4478a46e0439"; \
    elif [ "$TARGETARCH" = "amd64" ]; then \
        GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.5.0/gbdk-linux64.tar.gz"; \
        GBDK_SHA256="d7857a5f6d135ee4c249043ca26aad9f2ec8ab5d4106d97720d404114f42605c"; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi && \
    wget $GBDK_URL -O /tmp/gbdk.tar.gz && \
    echo "$GBDK_SHA256 /tmp/gbdk.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/gbdk.tar.gz -C /opt && \
    rm /tmp/gbdk.tar.gz

# Final stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash gbdk

COPY --from=builder /opt/gbdk /opt/gbdk

ENV SDCCDIR=/opt/gbdk/sdcc
ENV PATH="/opt/gbdk/bin:${PATH}"

# Switch to non-root user
USER gbdk
WORKDIR /home/gbdk

CMD ["bash"]