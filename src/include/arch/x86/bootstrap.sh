#!/usr/bin/env bash
_arch_x86_bootstrap_main() {
	_osiris_utils_output__create_partition_table msdos

	_osiris_utils_output__create_partition ext4 "${BOOT_PARTITION_SIZE}"
		_osiris_utils_output__set_partition_flag boot

	_osiris_utils_output__create_partition linux-swap "${SWAP_PARTITION_SIZE}"
	_osiris_utils_output__create_partition ext4
}
