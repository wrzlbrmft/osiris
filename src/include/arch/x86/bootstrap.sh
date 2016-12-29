#!/usr/bin/env bash
_arch_x86_bootstrap_main() {
	__create_partition_table msdos

	__create_partition ext4 "${BOOT_PARTITION_SIZE}"
		__set_partition_flag boot
		__create_filesystem ext4 boot

	__create_partition linux-swap "${SWAP_PARTITION_SIZE}"
		__create_filesystem swap swap

	__create_partition ext4
		__create_filesystem ext4 root
}
