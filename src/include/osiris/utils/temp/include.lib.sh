#!/usr/bin/env bash
__create_temp_dir() {
	local TMPDIR="$1"

	if [ -z "${TMPDIR}" ]; then
		TMPDIR="/tmp"
	fi

	__create_dir "${TMPDIR}"

	TMPDIR="${TMPDIR}" mktemp -d
}

__create_temp_file() {
	local TMPDIR="$1"

	if [ -z "${TMPDIR}" ]; then
		TMPDIR="/tmp"
	fi

	__create_dir "${TMPDIR}"

	TMPDIR="${TMPDIR}" mktemp
}
