#/usr/bin/env bash

CONTAINER_NAME=openvas_builder
CONTAINER_TAG=20.4.1

cp ../Makefile   .
cp ../install.mk .
cp ../build.mk   .

# build docker
docker build -t ${CONTAINER_NAME}:${CONTAINER_TAG} . || exit 127

# build deb
docker run -t --rm -v $(dirname $(pwd)):/data ${CONTAINER_NAME}:${CONTAINER_TAG}