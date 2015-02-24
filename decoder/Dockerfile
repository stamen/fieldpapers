FROM ubuntu:14.04

# Initialization

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get clean

# Core dependencies

RUN \
  apt-get install -y git-core build-essential && \
  apt-get clean

# System dependencies

RUN \
  apt-get install -y gdal-bin default-jre-headless python-cairo python-gdal python-dev python-imaging python-numpy python-pip python-requests php5-cli && \
  apt-get clean

# Application dependencies

RUN \
  pip install git+https://github.com/migurski/Blobdetector && \
  pip install ModestMaps raven

RUN \
  useradd -d /app -m fieldpapers

USER fieldpapers
ENV HOME /app
ENV PATH /app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WORKDIR /app

ADD . /app/

VOLUME ["/app"]
