#!/usr/bin/env bash
_osiris_internal_output_doneoutput_main() {
	case "${OUTPUT_TYPE}" in
		device)
			_osiris_utils_output__done_device
			;;

		image)
			_osiris_utils_output__done_image
			;;
	esac
}
