#!/usr/bin/env bash
_osiris_internal_output_initoutput_main() {
	if [ -z "${OUTPUT_FILE}" ]; then
		printf "fatal error: no output device or image file\n" >&2
		exit 1
	fi

	if [ -b "${OUTPUT_FILE}" ]; then
		__init_output_device "${OUTPUT_FILE}"
	else
		__init_output_image "${OUTPUT_FILE}"
	fi
}
