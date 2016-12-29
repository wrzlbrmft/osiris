#!/usr/bin/env bash
_osiris_internal_temp_inittemp_main() {
	if [ -z "${SCRIPT_TEMP_DIR}" ]; then
		SCRIPT_TEMP_DIR="$(_osiris_utils_temp__create_temp_dir "${TMPDIR}")"
	fi
}
