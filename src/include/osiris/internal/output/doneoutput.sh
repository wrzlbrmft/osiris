#!/usr/bin/env bash
_osiris_internal_output_doneoutput__done_device() {
	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi
}

_osiris_internal_output_doneoutput__done_image() {
	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: no output image file\n" >&2
		exit 1
	fi

	losetup -d "${OUTPUT_IMAGE_FILE}"
}

_osiris_internal_output_doneoutput_main() {
	case "${OUTPUT_TYPE}" in
		device)
			_osiris_internal_output_doneoutput__done_device
			;;

		image)
			_osiris_internal_output_doneoutput__done_image
			;;
	esac
}
