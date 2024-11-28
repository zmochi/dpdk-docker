Build docker images for host1, host2 and fw containers (fw may take ~10 minutes):
```bash
./launch.sh build
```

Run fw machine:
```bash
./launch.sh run fw
```

Attach:
```bash
docker attach fw
```

Enable hugepages, to run DPDK programs (as root):
```bash
source /dpdk/enable_hugepages.sh
```

To see DPDK in action, compile and run example application:
```bash
cd /dpdk/dpdk-23.11.2/examples/helloworld
sudo make
./build/helloworld
```

DPDK is installed on the container and its link/include flags are accessible through
```bash
pkg-config --cflags libdpdk
pkg-config --libs libdpdk
```
