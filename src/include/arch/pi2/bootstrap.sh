#!/usr/bin/env bash
_arch_pi2_bootstrap_main() {
	_osiris_utils_output__create_partition_table msdos

	_osiris_utils_output__create_partition fat32 "${BOOT_PARTITION_SIZE}"
		_osiris_utils_output__set_partition_flag boot

	_osiris_utils_output__create_partition ext4
}
