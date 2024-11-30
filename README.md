Start all containers and build if needed
```bash
docker compose up -d
```

Start only firewall (can replace firewall with ext_host/int_host) container

```bash
docker compose up firewall -d
```

Attach:
```bash
./attach.sh fw
```

Run `./attach.sh` without arguments to see options for arguments.

Stop all containers
```bash
docker compose down
```


Enable hugepages, to run DPDK programs (as root, password for `fw` user is `fw`):
```bash
sudo -s
source /dpdk/enable_hugepages.sh
```

To see DPDK in action, compile and run example application:
```bash
cd /dpdk/dpdk-23.11.2/examples/helloworld
sudo make
sudo ./build/helloworld
```

DPDK is installed on the container and its link/include flags are accessible through
```bash
pkg-config --cflags libdpdk
pkg-config --libs libdpdk
```
