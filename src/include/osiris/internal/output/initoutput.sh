#!/usr/bin/env bash
_osiris_internal_output_initoutput__init_device() {
	OUTPUT_DEVICE_FILE="$1"

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		OUTPUT_DEVICE_FILE="${OUTPUT_FILE}"
	fi

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi

	if [ -n "$(findmnt -ln -o SOURCE | grep "^${OUTPUT_DEVICE_FILE}")" ]; then
		printf "fatal error: output device is currently mounted ('%s')\n" "${OUTPUT_DEVICE_FILE}" >&2
		exit 1
	fi

	# TODO: delete partitions in reverse order

	dd if=/dev/zero of="${OUTPUT_DEVICE_FILE}" bs=1M count=1
	partprobe

	OUTPUT_TYPE="device"
}

_osiris_internal_output_initoutput__init_image() {
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

	if [ ! -d "$(dirname "${OUTPUT_IMAGE_FILE}")" ]; then
		mkdir -p "$(dirname "${OUTPUT_IMAGE_FILE}")"
	fi

	dd if=/dev/zero of="${OUTPUT_IMAGE_FILE}" bs=1M count="${OUTPUT_IMAGE_SIZE}" progress=status

	OUTPUT_DEVICE_FILE="$(losetup -f)"
	losetup -P "${OUTPUT_DEVICE_FILE}" "${OUTPUT_IMAGE_FILE}"

	OUTPUT_TYPE="image"
}

_osiris_internal_output_initoutput_main() {
	if [ -z "${OUTPUT_FILE}" ]; then
		printf "fatal error: no output device or image file\n" >&2
		exit 1
	fi

	if [ -b "${OUTPUT_FILE}" ]; then
		_osiris_internal_output_initoutput__init_device
	else
		_osiris_internal_output_initoutput__init_image
	fi
}
