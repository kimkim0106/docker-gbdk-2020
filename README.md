# docker-gbdk-2020

Docker container for Game Boy development using [GBDK-2020](https://github.com/gbdk-2020/gbdk-2020).

## Usage

### Build the Docker image

```bash
docker build -t docker-gbdk-2020:4.4.0 .
```

### Run the container

```bash
docker run -it --rm -v "$(pwd):/work" -w /work docker-gbdk-2020:4.4.0
```
