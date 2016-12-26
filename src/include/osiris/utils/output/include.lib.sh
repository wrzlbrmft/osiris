#!/usr/bin/env bash
_osiris_utils_output__get_partition_device_files_mounted() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		findmnt -ln -o SOURCE | grep "^${DEVICE_FILE}"
	fi
}

_osiris_utils_output__get_partition_device_files() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		lsblk -lnp -o NAME -x NAME "${DEVICE_FILE}" | grep "^${DEVICE_FILE}" | grep -v "^${DEVICE_FILE}$"
	fi
}

_osiris_utils_output__init_device() {
	OUTPUT_DEVICE_FILE="$1"

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		OUTPUT_DEVICE_FILE="${OUTPUT_FILE}"
	fi

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi

	if [ -n "$(_osiris_utils_output__get_partition_device_files_mounted)" ]; then
		printf "fatal error: output device is currently mounted ('%s')\n" "${OUTPUT_DEVICE_FILE}" >&2
		exit 1
	fi

	for DEVICE_FILE in "$(_osiris_utils_output__get_partition_device_files | sort -r)"; do
		dd if=/dev/zero of="${DEVICE_FILE}" bs=1M count=1
	done

	dd if=/dev/zero of="${OUTPUT_DEVICE_FILE}" bs=1M count=1
	partprobe

	OUTPUT_TYPE="device"
}

_osiris_utils_output__init_image() {
	OUTPUT_IMAGE_FILE="$1"

	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		OUTPUT_IMAGE_FILE="${OUTPUT_FILE}"
	fi

	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: no output image file\n" >&2
		exit 1
	fi

	if [ -f "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: output image file already exists ('%s')\n" "${OUTPUT_IMAGE_FILE}" >&2
		exit 1
	fi

	if [ -z "${OUTPUT_IMAGE_SIZE}" ]; then
		printf "fatal error: no output image size\n" >&2
		exit 1
	fi

	if [ ! -d "$(dirname "${OUTPUT_IMAGE_FILE}")" ]; then
		mkdir -p "$(dirname "${OUTPUT_IMAGE_FILE}")"
	fi

	dd if=/dev/zero of="${OUTPUT_IMAGE_FILE}" bs=1M count="${OUTPUT_IMAGE_SIZE}" progress=status

	OUTPUT_DEVICE_FILE="$(losetup -f)"
	losetup -P "${OUTPUT_DEVICE_FILE}" "${OUTPUT_IMAGE_FILE}"

	OUTPUT_TYPE="image"
}

_osiris_utils_output__done_device() {
	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi
}

_osiris_utils_output__done_image() {
	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: no output image file\n" >&2
		exit 1
	fi

	losetup -d "${OUTPUT_IMAGE_FILE}"
}
