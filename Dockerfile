FROM ubuntu:latest

# install some generally useful stuff
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    curl \
    iproute2 \
    iputils-ping \
    net-tools \
    openssh-server \
    sudo \
    tcpdump \
    telnet \
    traceroute \
    wget \
    && rm -rf /var/lib/apt/lists/*

# add a generic nanog user
RUN useradd -m nanog && echo "nanog:nanog" | chpasswd && adduser nanog sudo
USER nanog
CMD /bin/bash

