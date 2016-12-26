#!/usr/bin/env bash
_osiris_internal_output_initoutput__init_device() {
	OUTPUT_DEVICE="$1"

	printf "init output device\n"

	OUTPUT_TYPE="device"
}

_osiris_internal_output_initoutput__init_image() {
	OUTPUT_IMAGE="$1"

	printf "init output image\n"

	OUTPUT_TYPE="image"
}

_osiris_internal_output_initoutput_main() {
	if [ -z "${OUTPUT_FILE}" ]; then
		printf "fatal error: no output device or image file\n" >&2
		exit 1
	fi

	if [ -b "${OUTPUT_FILE}" ]; then
		_osiris_internal_output_initoutput__init_device "${OUTPUT_FILE}"
	else
		_osiris_internal_output_initoutput__init_image "${OUTPUT_FILE}"
	fi
}
