#!/usr/bin/env bash
_osiris_utils_temp__create_temp_dir() {
	local TMPDIR="$1"

	if [ -z "${TMPDIR}" ]; then
		TMPDIR="/tmp"
	fi

	_osiris_utils_fs__create_dir "${TMPDIR}"

	TMPDIR="${TMPDIR}" mktemp -d
}

_osiris_utils_temp__create_temp_file() {
	local TMPDIR="$1"

	if [ -z "${TMPDIR}" ]; then
		TMPDIR="/tmp"
	fi

	_osiris_utils_fs__create_dir "${TMPDIR}"

	TMPDIR="${TMPDIR}" mktemp
}
