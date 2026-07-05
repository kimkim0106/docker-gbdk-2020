---
name: gbdk-build
description: Build Game Boy ROMs using the docker-gbdk-2020 Docker image (GBDK-2020 toolchain). Use when compiling C or ASM sources into .gb/.gbc ROMs, running make in a GBDK project, or when lcc/sdcc is needed without a local GBDK install.
---

# Building Game Boy ROMs with docker-gbdk-2020

All GBDK-2020 tools (`lcc`, `sdcc`, `sdasgb`, `makebin`, etc.) run inside the
`docker-gbdk-2020` Docker image. Never assume GBDK is installed on the host.

## Image setup

Current image tag: `docker-gbdk-2020:4.5.0` (GBDK-2020 4.5.0).

Check whether the image exists before the first build:

```bash
docker image inspect docker-gbdk-2020:4.5.0 --format 'ok' 2>/dev/null
```

If missing, build it directly from the GitHub repository (works on both
arm64 and amd64):

```bash
docker build -t docker-gbdk-2020:4.5.0 https://github.com/kimkim0106/docker-gbdk-2020.git
```

## Running builds

Mount the project root at `/work` and run the build command there:

```bash
# Project with a Makefile
docker run --rm -v "$(pwd):/work" -w /work docker-gbdk-2020:4.5.0 make

# Single C file, no Makefile
docker run --rm -v "$(pwd):/work" -w /work docker-gbdk-2020:4.5.0 \
  lcc -o main.gb main.c

# Game Boy Color ROM
docker run --rm -v "$(pwd):/work" -w /work docker-gbdk-2020:4.5.0 \
  lcc -Wm-yc -o main.gbc main.c
```

Notes:

- Always use `--rm`; do not keep containers around between builds.
- Run the container from the project root so relative paths in Makefiles work.
- `make clean` and other Makefile targets run the same way:
  `docker run --rm -v "$(pwd):/work" -w /work docker-gbdk-2020:4.5.0 make clean`

## Environment inside the container

- `PATH` includes `/opt/gbdk/bin` — call `lcc`, `sdcc`, etc. by name.
- `SDCCDIR=/opt/gbdk/sdcc` is preset.
- GBDK libraries and headers are under `/opt/gbdk/lib` and `/opt/gbdk/include`.
- The container runs as non-root user `gbdk` (uid 1000). If build outputs on
  the host end up with unexpected ownership (mainly on Linux hosts), add
  `--user "$(id -u):$(id -g)"` to the `docker run` command.
- Only `make` and the GBDK toolchain are installed. If a project's Makefile
  needs other tools (Python, ImageMagick, etc.), run those steps on the host
  and only run the GBDK compile/link steps in the container.

## Troubleshooting

- `lcc: not found` on the host → the command was run outside the container;
  wrap it in `docker run` as shown above.
- `Unsupported architecture` during image build → the Docker platform is not
  arm64/amd64; pass `--platform linux/amd64` to `docker build` and `docker run`.
- Makefile hardcodes a GBDK path like `/opt/gbdk` → it matches this image's
  layout already; if it points elsewhere, override with
  `make GBDK_HOME=/opt/gbdk`.
