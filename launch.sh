#!/usr/bin/env bash

INTERNAL_SUBNET=10.1.1.0/24
EXTERNAL_SUBNET=10.1.2.0/24
INTERNAL_NETNAME=fw-internal
EXTERNAL_NETNAME=fw-external
HOST1_IMGNAME=host1_img
HOST2_IMGNAME=host2_img
fw_IMGNAME=fw_img
VER=24.04 # ubuntu version for container

print_usage() {
	cat <<EOT >&1
Usage:
	$0 build
	$0 run <host1 | host2 | fw>
EOT
}

WORKDIR=.

err() {
	docker kill host1
	docker kill host2
	docker kill fw
	echo "$1"
	exit "$2"
}

build_img() { # args: directory containing Dockerfile, image name, username (for machine non-root user)
	DIR=$1
	IMG_NAME=$2
	USERNAME=$3

	cd "$DIR" || err "Couldn't find $DIR directory" 1
	docker buildx build \
		-t "$IMG_NAME" \
		--platform=linux/amd64 \
		--build-arg UBUNTU_VER="$VER" \
		--build-arg username="$USERNAME" \
		. || err "Couldn't build container for directory $DIR" 1
	cd -
}

start_container() { # args:
	# image name
	# ubuntu version
	# container name
	# network name
	# container ip (for NIC)
	# container gateway (host part should be zero-filled)
	# container username (linux user)
	IMG_NAME=$1
	VER=$2
	CONTAINER_NAME=$3
	NET_NAME=$4
	NIC_IP=$5
	NET_GATEWAY=$6
	USER=$7
	VOL_NAME="$CONTAINER_NAME""_data"

	docker run --rm --privileged -dit \
		--platform=linux/amd64 \
		--name "$CONTAINER_NAME" \
		--hostname "$CONTAINER_NAME" \
		--network "$NET_NAME" \
		--ip "$NIC_IP" \
		-v "$VOL_NAME":/home/"$USER" \
		"$IMG_NAME" || err "Couldn't run container image $IMG_NAME" 1

	# docker exec "$CONTAINER_NAME" # TODO: set NIC gateway here if $NET_GATEWAY is not empty
}

host1_NIC_IP=10.1.1.10
host2_NIC_IP=10.1.2.10
NIC2_IP=10.1.1.3
NIC3_IP=10.1.2.3

if [[ "$1" = "build" ]]; then
	# create network topology - internal and external network
	docker network create --subnet "$INTERNAL_SUBNET" "$INTERNAL_NETNAME"
	docker network create --subnet "$EXTERNAL_SUBNET" "$EXTERNAL_NETNAME"

	# build all machine images
	build_img "$WORKDIR/host1" $HOST1_IMGNAME host1
	build_img "$WORKDIR/host2" $HOST2_IMGNAME host1
	build_img "$WORKDIR/fw" $fw_IMGNAME fw
elif [[ "$1" = "run" ]]; then
	if [[ "$2" = "host1" ]]; then
		start_container $HOST1_IMGNAME "$UBUNTU_VER" host1 $INTERNAL_NETNAME $host1_NIC_IP $NIC2_IP host1
	elif [[ "$2" = "host2" ]]; then
		start_container $HOST2_IMGNAME "$UBUNTU_VER" host2 $EXTERNAL_NETNAME $host2_NIC_IP $NIC3_IP host2
	elif [[ "$2" = "fw" ]]; then
		# start_container starts fw, connecting it to internal network. the next `docker network connect` connects it to the external network
		start_container $fw_IMGNAME "$UBUNTU_VER" fw $INTERNAL_NETNAME $NIC2_IP "" fw
		docker network connect --ip $NIC3_IP $EXTERNAL_NETNAME fw
	else
		print_usage
	fi
else
	print_usage
fi
