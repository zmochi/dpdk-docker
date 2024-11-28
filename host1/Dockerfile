ARG UBUNTU_VER=24.04

FROM ubuntu:$UBUNTU_VER

ARG USERNAME=host1
ENV USERNAME=${USERNAME}

RUN apt-get update && \
apt-get install -y \
iproute2 \
iputils-ping make \
gcc \
git \
netcat-openbsd \
sudo \
build-essential

RUN useradd --create-home --shell /bin/bash $USERNAME
RUN adduser $USERNAME sudo
# set password for user, WARNING: insecure
RUN echo "${USERNAME}:fw" | chpasswd

WORKDIR /home/$USERNAME
USER $USERNAME
