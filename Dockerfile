# Build stage
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    flex \
    bison \
    libboost-dev \
    texinfo \
    zlib1g \
    zlib1g-dev \
    g++ \
    make \
    subversion \
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SDCC build
RUN svn checkout -r 14650 svn://svn.code.sf.net/p/sdcc/code/trunk /opt/sdcc-14650

WORKDIR /opt/sdcc-14650
RUN wget https://github.com/gbdk-2020/gbdk-2020-sdcc/releases/download/patches/gbdk-4.3-nes_banked_nonbanked_no_overlay_locals_v8_combined.patch -O /tmp/gbdk.patch \
    && echo "0c847acfbf2c4b60561a5fbda53bd89cbda8ac7552f57ac5c1de20794837ca54 /tmp/gbdk.patch" | sha256sum -c - \
    && patch -p0 -f < /tmp/gbdk.patch \
    && rm /tmp/gbdk.patch

WORKDIR /opt/sdcc-14650/sdcc
RUN ./configure --disable-shared --enable-gbz80-port  --enable-z80-port  --enable-mos6502-port  --enable-mos65c02-port  --disable-r800-port  --disable-mcs51-port  --disable-z180-port  --disable-r2k-port  --disable-r2ka-port  --disable-r3ka-port  --disable-tlcs90-port  --disable-ez80_z80-port  --disable-z80n-port  --disable-ds390-port  --disable-ds400-port  --disable-pic14-port  --disable-pic16-port  --disable-hc08-port  --disable-s08-port  --disable-stm8-port  --disable-pdk13-port  --disable-pdk14-port  --disable-pdk15-port  --disable-ucsim  --disable-doc  --disable-device-lib \
    && make \
    && mkdir -p /opt/gbdk/sdcc \
    && cp -rf bin /opt/gbdk/sdcc/bin \
    && cp -f src/sdcc /opt/gbdk/sdcc/bin \
    && cp -f support/sdbinutils/binutils/sdar /opt/gbdk/sdcc/bin \
    && cp -f support/sdbinutils/binutils/sdranlib /opt/gbdk/sdcc/bin \
    && cp -f support/sdbinutils/binutils/sdobjcopy /opt/gbdk/sdcc/bin \
    && cp -f support/sdbinutils/binutils/sdnm /opt/gbdk/sdcc/bin \
    && cp -f support/cpp/gcc/cc1 /opt/gbdk/sdcc/bin \
    && cp -f support/cpp/gcc/cpp /opt/gbdk/sdcc/bin/sdcpp \
    && strip /opt/gbdk/sdcc/bin/* || true \
    && find /opt/gbdk/sdcc/bin -type f -name "*.in" -delete \
    && find /opt/gbdk/sdcc/bin -type f -name "Makefile" -delete \
    && find /opt/gbdk/sdcc/bin -type f -name "README" -delete \
    && mkdir -p /opt/gbdk/sdcc/libexec/sdcc \
    && mv /opt/gbdk/sdcc/bin/cc1 /opt/gbdk/sdcc/libexec/sdcc

ENV SDCCDIR=/opt/gbdk/sdcc

# GBDK build
RUN wget https://github.com/gbdk-2020/gbdk-2020/archive/refs/tags/4.3.0.tar.gz -O /tmp/gbdk.tar.gz \
    && echo "f958e50c6f12bc5e28e4f0699969d59d794a981f5c4ab7f3aaba4d953d78806d /tmp/gbdk.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/gbdk.tar.gz -C /opt/gbdk --strip-components=1 \
    && rm /tmp/gbdk.tar.gz

WORKDIR /opt/gbdk
RUN make \
    && make install \
    && make clean \
    && rm -rf /opt/sdcc-14650

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