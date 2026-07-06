# docker-gbdk-2020

Docker container for Game Boy development using [GBDK-2020](https://github.com/gbdk-2020/gbdk-2020).

## Usage

### Build the Docker image

```bash
docker build -t docker-gbdk-2020:4.5.0 .
```

### Run the container

```bash
docker run -it --rm -v "$(pwd):/work" -w /work docker-gbdk-2020:4.5.0
```

## Claude Code plugin

This repository is also a [Claude Code](https://claude.com/claude-code) plugin
marketplace. The `gbdk-build` plugin teaches Claude Code how to build Game Boy
ROMs with this Docker image, so any project can use it without a local GBDK
install.

```
/plugin marketplace add kimkim0106/docker-gbdk-2020
/plugin install gbdk-build@docker-gbdk-2020
```
