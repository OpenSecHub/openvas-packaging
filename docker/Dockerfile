FROM ubuntu:20.04

# update
ENV DEBIAN_FRONTEND noninteractive
#RUN rm -f /etc/apt/sources.list
#ADD sources.list /etc/apt/
RUN apt-get update
RUN apt-get install -y make curl wget sudo

# install build-tools
ADD Makefile   /
ADD build.mk   /
ADD install.mk /
RUN make init
RUN rm -f Makfile build.mk install.mk

RUN mkdir /data

ADD build.sh /
RUN chmod +x /build.sh

# set entrypoint
ENTRYPOINT ["/build.sh"]