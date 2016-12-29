#!/usr/bin/env bash
_osiris_utils_fs__create_dir() {
	local DIR="$1"

	if [ ! -d "${DIR}" ]; then
		mkdir -p "${DIR}"
	fi
}

_osiris_utils_fs__create_file_dir() {
	local FILE="$1"

	if [ -n "${FILE}" ]; then
		_osiris_utils_fs__create_dir "$(dirname "${FILE}")"
	fi
}

_osiris_utils_fs__create_file() {
	local FILE="$1"
	local SIZE="$2"

	if [ -z "${SIZE}" ]; then
		SIZE="1"
	fi

	if [ -n "${FILE}" ]; then
		_osiris_utils_fs__create_file_dir "${FILE}"

		dd if=/dev/zero of="${FILE}" bs=1M count="${SIZE}" status=progress
	fi
}
