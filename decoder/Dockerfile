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
  apt-get install -y gdal-bin python-cairo python-gdal python-dev python-imaging python-numpy python-pip python-requests python-virtualenv php5-cli zbar-tools && \
  apt-get clean

# Application dependencies

RUN \
  apt-get install -y python-cairo python-gdal python-imaging python-numpy && \
  apt-get clean

ENV VIRTUAL_ENV /opt/paper/env
ENV PATH /opt/paper/env/bin:/opt/paper:$PATH

ADD requirements.txt /opt/paper/requirements.txt

RUN \
  cd /opt/paper && \
  virtualenv env --system-site-packages && \
  pip install -r requirements.txt

ADD . /opt/paper/

VOLUME ["/opt/paper"]
