#!/usr/bin/env bash
__create_filesystem() {
	local TYPE="$1"
	local LABEL="$2"
	local DEVICE_FILE="$3"

	if [ -n "${TYPE}" ]; then
		if [ -z "${DEVICE_FILE}" ]; then
			DEVICE_FILE="$(__get_partition_device_file_last "${OUTPUT_DEVICE_FILE}")"
		fi

		if [ -n "${DEVICE_FILE}" ]; then
			case "${TYPE}" in
				ext2|ext3|ext4)
					if [ -n "${LABEL}" ]; then
						mkfs -t "${TYPE}" -L "${LABEL}" "${DEVICE_FILE}"
					else
						mkfs -t "${TYPE}" "${DEVICE_FILE}"
					fi
					;;

				swap)
					if [ -n "${LABEL}" ]; then
						mkswap -L "${LABEL}" "${DEVICE_FILE}"
					else
						mkswap "${DEVICE_FILE}"
					fi
					;;

				fat32)
					if [ -n "${LABEL}" ]; then
						mkfs -t fat -F 32 -n "${LABEL}" "${DEVICE_FILE}"
					else
						mkfs -t fat -F 32 "${DEVICE_FILE}"
					fi
					;;
			esac
		fi
	fi
}

__create_dir() {
	local DIR="$1"

	if [ ! -d "${DIR}" ]; then
		mkdir -p "${DIR}"
	fi
}

__create_file_dir() {
	local FILE="$1"

	if [ -n "${FILE}" ]; then
		__create_dir "$(dirname "${FILE}")"
	fi
}

__create_file() {
	local FILE="$1"
	local SIZE="$2"

	if [ -z "${SIZE}" ]; then
		SIZE="1"
	fi

	if [ -n "${FILE}" ]; then
		__create_file_dir "${FILE}"

		dd if=/dev/zero of="${FILE}" bs=1M count="${SIZE}" status=progress
	fi
}
