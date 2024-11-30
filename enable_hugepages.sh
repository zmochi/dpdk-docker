echo 1024 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages &&
	mkdir /mnt/huge &&
	mount -t hugetlbfs pagesize=1GB /mnt/huge
