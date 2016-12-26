#!/usr/bin/env bash
_osiris_internal_output_doneoutput__done_image() {
	printf "done output image\n"
}

_osiris_internal_output_doneoutput_main() {
	case "${OUTPUT_TYPE}" in
		device)
			;;

		image)
			_osiris_internal_output_doneoutput__done_image
			;;
	esac
}
