#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_FILE="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"
SCRIPT_NAME="$(SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"; printf "%s" "${SCRIPT_NAME%.*}")"

declare -a INCLUDE_PATHS

__help() {
	cat << __END
help
__END
}

# main

declare -a CONFIG_FILES
declare -a PHASES
declare -a STEPS

while getopts :hc:i:o:p:s:y OPT; do
	case "${OPT}" in
		h)
			__help
			exit 0
			;;

		c)
			CONFIG_FILE="${OPTARG}"
			if [ -f "${CONFIG_FILE}" ]; then
				CONFIG_FILES+=("${CONFIG_FILE}")
			else
				printf "fatal error: config file not found ('%s')\n" "${CONFIG_FILE}" >&2
				exit 1
			fi
			;;

		i)
			INCLUDE_PATH="${OPTARG}"
			if [ -d "${INCLUDE_PATH}" ]; then
				INCLUDE_PATHS+=("${INCLUDE_PATH}")
			else
				printf "fatal error: include path not found ('%s')\n" "${INCLUDE_PATH}" >&2
				exit 1
			fi
			;;

		o)
			OUTPUT_FILE="${OPTARG}"
			;;

		p)
			PHASE="${OPTARG}"
			PHASES+=("${PHASE}")
			;;

		s)
			STEP="${OPTARG}"
			STEPS+=("${STEP}")
			;;

		y)
			YES="1"
			;;

		:)
			printf "fatal error: " >&2
			case "${OPTARG}" in
				c)
					printf "missing config file" >&2
					;;

				i)
					printf "missing include path" >&2
					;;

				o)
					printf "missing output device or image file" >&2
					;;

				p)
					printf "missing phase" >&2
					;;

				s)
					printf "missing step" >&2
					;;
			esac
			printf "\n" >&2
			exit 1
			;;

		\?)
			printf "fatal error: invalid option ('-%s')\n" "${OPTARG}" >&2
			__help
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "$@" ]; then
	printf "fatal error: no include\n" >&2
	exit 1
fi

exit 0
