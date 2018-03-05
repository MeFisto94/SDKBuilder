FROM ubuntu:rolling
MAINTAINER MeFisto94

RUN mkdir /sdk_build/ && mkdir /dist && apt-get -y update && apt-get -y upgrade && apt-get -y install openjdk-8-jdk git maven patch p7zip-full cabextract curl cpio zip ant && cd /sdk_build/
ENV TRAVIS SDK_DOCKER
# ENV TRAVIS_TAG v3.2.0-stable-sdk1 # Should be specified by the Command Line during runtime.
WORKDIR /sdk_build/
COPY docker_entrypoint.sh /sdk_build/
VOLUME /dist

CMD ["/bin/sh", "/sdk_build/docker_entrypoint.sh"]
