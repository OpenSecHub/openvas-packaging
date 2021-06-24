#/usr/bin/env bash

#set -x

CONTAINER_NAME=openvas_builder
CONTAINER_TAG=20.4.1

BUILD_DOCKER="yes"
BUILD_DEB="yes"
IN_DOCKER="no"

########################################################
function build_docker() {

    rm -f Makefile *.mk
    cp ../Makefile   .
    cp ../install.mk .
    cp ../build.mk   .

    # build docker
    docker build -t ${CONTAINER_NAME}:${CONTAINER_TAG} . || exit 127
    rm -f Makefile *.mk
}

# build deb
function build_deb() {
    docker run -t --rm -v $(dirname $(pwd)):/data ${CONTAINER_NAME}:${CONTAINER_TAG}

    # deb in ../build/ dir
    ls $(dirname $(pwd))/build/*.deb
}

function in_docker() {
    docker run -it --rm --entrypoint /bin/bash -v $(dirname $(pwd)):/data ${CONTAINER_NAME}:${CONTAINER_TAG}
}

function help() {
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "    --not-build-docker  [Optional] do not build docker"
    echo "    --not-build-deb     [Optional] do not build sources"
    echo "    -h, --help          Show this help."
    echo
    exit $1
}

function main() {
    while [ -n "$1" ]
    do
        case "$1" in
        "--not-build-docker")
            BUILD_DOCKER="no"
            shift 1
            ;;
        "--not-build-deb")
            BUILD_DEB="no"
            shift 1
            ;;
        "--in-docker")
            BUILD_DOCKER="no"
            BUILD_DEB="no"
            IN_DOCKER="yes"
            shift 1
            ;;
        "-h"|"--help")
            help 0
            ;;
        *)
            help 1
        esac
    done

    if [[ ${BUILD_DOCKER} == "yes" ]] ; then
        build_docker
    fi

    if [[ ${BUILD_DEB} == "yes" ]] ; then
        build_deb
    fi

    if [[ ${IN_DOCKER} == "yes" ]] ; then
        in_docker
    fi
}

main "$@"
