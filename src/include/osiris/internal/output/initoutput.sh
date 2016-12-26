#!/usr/bin/env bash
_osiris_internal_output_initoutput_main() {
	if [ -z "${OUTPUT_FILE}" ]; then
		printf "fatal error: no output device or image file\n" >&2
		exit 1
	fi

	if [ -b "${OUTPUT_FILE}" ]; then
		_osiris_internal_output__init_device
	else
		_osiris_internal_output__init_image
	fi
}
