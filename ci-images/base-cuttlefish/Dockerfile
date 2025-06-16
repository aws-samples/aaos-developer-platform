## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0

FROM ubuntu:20.04


ENV GOCACHE=/root/go/cache
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y libprotobuf-dev protobuf-compiler nfs-common binutils u-boot-tools
RUN apt-get install -y git devscripts config-package-dev debhelper-compat golang libssl-dev
RUN apt-get install -y clang meson libfmt-dev libgflags-dev libjsoncpp-dev libcurl4-openssl-dev libgoogle-glog-dev libgtest-dev libxml2-dev uuid-dev libprotobuf-c-dev libz3-dev
RUN apt-get install dpkg-dev -y
RUN apt-get -y install python3-pip
RUN apt-get -y install awscli
RUN apt-get -y install unzip
RUN apt-get install -y libprotobuf-dev protobuf-compiler nfs-common binutils u-boot-tools
RUN apt-get install -y git devscripts config-package-dev debhelper-compat golang
RUN apt-get -y install unzip


WORKDIR /home/ubuntu

RUN git clone https://github.com/google/android-cuttlefish --branch v0.9.27

WORKDIR android-cuttlefish

RUN apt-get install libprotobuf-dev protobuf-compiler -y
RUN apt-get install dpkg-dev -y
RUN apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y

COPY loop.sh .
RUN chmod +x loop.sh
RUN ./loop.sh



RUN ls && ls && apt install -y ./cuttlefish-base_*.deb
RUN apt install -y ./cuttlefish-user_*.deb
 

RUN adduser ubuntu
RUN groupadd render
RUN usermod -aG kvm,cvdnetwork,render ubuntu
RUN usermod -aG kvm,cvdnetwork,render root
