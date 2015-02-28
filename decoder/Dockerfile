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
  apt-get install -y gdal-bin default-jre-headless python-cairo python-gdal python-dev python-imaging python-numpy python-pip python-requests python-virtualenv php5-cli zbar-tools && \
  apt-get clean

# Application dependencies

RUN \
  apt-get install -y python-cairo python-gdal python-imaging python-numpy

RUN \
  useradd -d /app -m fieldpapers

USER fieldpapers
ENV HOME /app
WORKDIR /app
ENV VIRTUAL_ENV /app/env
ENV PATH /app/env/bin:/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD . /app/

RUN \
  virtualenv env --system-site-packages && \
  pip install -r requirements.txt

VOLUME ["/app"]
