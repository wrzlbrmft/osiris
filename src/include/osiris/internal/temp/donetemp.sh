#!/usr/bin/env bash
_osiris_internal_temp_donetemp_main() {
	if [ -z "${KEEP_SCRIPT_TEMP_DIR}" ] && [ -d "${SCRIPT_TEMP_DIR}" ]; then
		rm -rf --preserve-root "${SCRIPT_TEMP_DIR}"
	fi
}
