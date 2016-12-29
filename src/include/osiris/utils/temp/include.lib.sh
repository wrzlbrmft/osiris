#!/usr/bin/env bash
_osiris_utils_temp__create_temp_dir() {
	local TMPDIR="$1"

	if [ -z "${TMPDIR}" ]; then
		TMPDIR="/tmp"
	fi

	TMPDIR="${TMPDIR}" mktemp -d
}
