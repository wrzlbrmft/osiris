#!/usr/bin/env bash
_osiris_internal_temp_inittemp_main() {
	if [ -z "${SCRIPT_TEMP_DIR}" ]; then
		SCRIPT_TEMP_DIR="$(__create_temp_dir "${TMPDIR}")"
	else
		__create_dir "${SCRIPT_TEMP_DIR}"
	fi
}
