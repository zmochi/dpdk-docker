ARG UBUNTU_VER=24.04

FROM ubuntu:$UBUNTU_VER

ENV USERNAME=host

ENV DEFAULT_GATEWAY=0
ENV SUBNET=0

RUN apt-get update && \
apt-get install -y \
iproute2 \
iputils-ping make \
gcc \
git \
netcat-openbsd \
net-tools \
tcpdump \
sudo \
build-essential

RUN useradd --create-home --shell /bin/bash $USERNAME
RUN adduser $USERNAME sudo
# set password for user, WARNING: insecure
RUN echo "${USERNAME}:fw" | chpasswd

# hacky trick to set default gateway
COPY ./set_def_gateway.sh /set_def_gateway.sh
ENTRYPOINT chmod u+x /set_def_gateway.sh && /set_def_gateway.sh $SUBNET $DEFAULT_GATEWAY

# RUN ip route add default via $DEFAULT_GATEWAY

# WORKDIR /home/$USERNAME
# USER $USERNAME
