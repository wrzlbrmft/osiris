#!/usr/bin/env bash
__create_image_file() {
	local IMAGE_FILE="$1"
	local IMAGE_SIZE="$2"

	if [ -z "${IMAGE_FILE}" ]; then
		IMAGE_FILE="${OUTPUT_IMAGE_FILE}"
	fi

	if [ -z "${IMAGE_SIZE}" ]; then
		IMAGE_SIZE="${OUTPUT_IMAGE_SIZE}"
	fi

	if [ -n "${IMAGE_FILE}" ] && [ -n "${IMAGE_SIZE}" ]; then
		__create_file "${IMAGE_FILE}" "${IMAGE_SIZE}"
	fi
}

__init_output_device() {
	OUTPUT_DEVICE_FILE="$1"

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		OUTPUT_DEVICE_FILE="${OUTPUT_FILE}"
	fi

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi

	if [ "0" != "$(__get_mounted_partition_device_files_count "${OUTPUT_DEVICE_FILE}")" ]; then
		printf "fatal error: output device is currently mounted ('%s')\n" "${OUTPUT_DEVICE_FILE}" >&2
		exit 1
	fi

	__delete_all_partitions "${OUTPUT_DEVICE_FILE}"
	__delete_partition_table "${OUTPUT_DEVICE_FILE}"

	OUTPUT_TYPE="device"
}

__init_output_image() {
	OUTPUT_IMAGE_FILE="$1"
	local IMAGE_SIZE="$2"

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

	if [ -n "${IMAGE_SIZE}" ]; then
		OUTPUT_IMAGE_SIZE="${IMAGE_SIZE}"
	fi

	if [ -z "${OUTPUT_IMAGE_SIZE}" ]; then
		printf "fatal error: no output image size\n" >&2
		exit 1
	fi

	__create_image_file "${OUTPUT_IMAGE_FILE}" "${OUTPUT_IMAGE_SIZE}"

	OUTPUT_DEVICE_FILE="$(losetup -f)"
	losetup -P "${OUTPUT_DEVICE_FILE}" "${OUTPUT_IMAGE_FILE}"

	OUTPUT_TYPE="image"
}

__done_output_device() {
	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi
}

__done_output_image() {
	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: no output image file\n" >&2
		exit 1
	fi

	losetup -d "${OUTPUT_DEVICE_FILE}"
}
