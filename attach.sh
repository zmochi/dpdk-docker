#!/usr/bin/env bash

print_usage() {
	cat <<EOT >&1
Usage:
	$0 <fw | host1 | host2>
EOT
}

if [ "$1" != "fw" ] && [ "$1" != "host1" ] && [ "$1" != "host2" ]; then
	print_usage
	exit 1
fi

echo -e "Press Ctrl+D to exit\n"
docker exec -it "$1" bash
