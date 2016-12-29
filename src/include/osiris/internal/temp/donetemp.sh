#!/usr/bin/env bash
_osiris_internal_temp_donetemp_main() {
	if [ -d "${SCRIPT_TEMP_DIR}" ]; then
		rm -rf --preserve-root "${SCRIPT_TEMP_DIR}"
	fi
}
