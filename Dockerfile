# Build stage
FROM debian:bookworm-slim AS builder

ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/gbdk

# Download and extract GBDK-2020 by TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-linux-arm64.tar.gz"; \
        GBDK_SHA256="4b1c2546ecdee56d622c0c48b843bd7efc2a14fc5a1ac61837c0467006b10fe2"; \
    elif [ "$TARGETARCH" = "amd64" ] || [ "$TARGETARCH" = "x86_64" ]; then \
        GBDK_URL="https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-linux64.tar.gz"; \
        GBDK_SHA256="8a292e767610ccfa73c2c14d73e7900075b425f68329f1a8eb7697015915edad"; \
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