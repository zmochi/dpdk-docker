ARG UBUNTU_VER=24.04

FROM ubuntu:$UBUNTU_VER

ARG USERNAME=fw
ENV USERNAME=${USERNAME}
ARG DPDK_VER=23.11.2
ENV DPDK_VER=${DPDK_VER}

RUN apt-get update && \
apt-get install -y \
iproute2 \
iputils-ping make \
gcc \
git \
curl \
tar \
netcat-openbsd \
sudo \
build-essential \
python3 \
libnuma-dev \
meson \
ninja-build \
python3-pyelftools \
pkg-config \
vim \
libpcap-dev \
man-db \
tcpdump \
net-tools \
unminimize

RUN yes | unminimize

# add non-root user
RUN useradd --create-home --shell /bin/bash $USERNAME
RUN adduser $USERNAME sudo
# set password for user, WARNING: insecure
RUN echo "${USERNAME}:fw" | chpasswd

# ipv4 forwarding
# RUN sysctl -w net.ipv4.ip_forward=1

WORKDIR /dpdk

# download and unpack dpdk
RUN curl -O https://fast.dpdk.org/rel/dpdk-$DPDK_VER.tar.xz
RUN mkdir dpdk-$DPDK_VER
RUN tar --strip-components=1 -C dpdk-$DPDK_VER -xJf dpdk-$DPDK_VER.tar.xz

# compile dpdk
WORKDIR /dpdk/dpdk-$DPDK_VER
RUN meson setup build
WORKDIR build
RUN ninja
RUN meson install
RUN ldconfig

COPY ./enable_hugepages.sh /dpdk/enable_hugepages.sh

WORKDIR /home/$USERNAME
USER $USERNAME
