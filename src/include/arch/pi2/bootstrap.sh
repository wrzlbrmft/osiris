#!/usr/bin/env bash
_arch_pi2_bootstrap_main() {
	__create_partition_table msdos

	__create_partition fat32 "${BOOT_PARTITION_SIZE}"
		__set_partition_flag boot
		__create_filesystem fat32 boot

	__create_partition ext4
		__create_filesystem ext4 root

	__mount root "${SCRIPT_TEMP_DIR}/mnt"
	__mount boot /boot
}
