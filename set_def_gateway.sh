#!/usr/bin/env bash

set -m

sleep infinity &

ip route add "$1" via "$2"

fg %1
