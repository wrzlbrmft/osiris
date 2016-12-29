#!/usr/bin/env bash
__create_filesystem() {
	local FILESYSTEM_TYPE="$1"
	local FILESYSTEM_LABEL="$2"
	local DEVICE_FILE="$3"

	if [ -n "${FILESYSTEM_TYPE}" ]; then
		if [ -z "${DEVICE_FILE}" ]; then
			DEVICE_FILE="$(__get_partition_device_file_last "${OUTPUT_DEVICE_FILE}")"
		fi

		if [ -n "${DEVICE_FILE}" ]; then
			case "${FILESYSTEM_TYPE}" in
				ext2|ext3|ext4)
					if [ -n "${FILESYSTEM_LABEL}" ]; then
						mkfs -t "${FILESYSTEM_TYPE}" -L "${FILESYSTEM_LABEL}" "${DEVICE_FILE}"
					else
						mkfs -t "${FILESYSTEM_TYPE}" "${DEVICE_FILE}"
					fi
					;;

				swap)
					if [ -n "${FILESYSTEM_LABEL}" ]; then
						mkswap -L "${FILESYSTEM_LABEL}" "${DEVICE_FILE}"
					else
						mkswap "${DEVICE_FILE}"
					fi
					;;

				fat32)
					if [ -n "${FILESYSTEM_LABEL}" ]; then
						mkfs -t fat -F 32 -n "${FILESYSTEM_LABEL}" "${DEVICE_FILE}"
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
