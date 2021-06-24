# Build Openvas in Docker


> If you want to run openvas in docker, please see [here](https://github.com/immauss/openvas).

### usage

```bash
Usage: ./run.sh [OPTIONS]

    --not-build-docker  [Optional] do not build docker
    --not-build-deb     [Optional] do not build sources
    -h, --help          Show this help.
```

### build

```bash
git clone https://github.com/OpenSecHub/openvas-packaging.git
cd openvas-packaging/docker
./run.sh # build docker and sources
# ./run.sh --not-build-docker # only build sources

# deb package in openvas-packaging/build directory
# all build log in openvas-packaging/build/*/
```