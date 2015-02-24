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
  apt-get install -y gdal-bin default-jre-headless python-cairo python-dev python-imaging python-numpy python-pip python-requests && \
  apt-get clean

# Application dependencies

RUN \
  pip install git+https://github.com/migurski/Blobdetector && \
  pip install ModestMaps raven

RUN \
  useradd -d /app -m fieldpapers

USER fieldpapers
ENV HOME /app
WORKDIR /app

ADD . /app/
