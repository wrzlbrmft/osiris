#!/usr/bin/env bash
_osiris_internal_output_doneoutput_main() {
	case "${OUTPUT_TYPE}" in
		device)
			__done_output_device
			;;

		image)
			__done_output_image
			;;
	esac
}
