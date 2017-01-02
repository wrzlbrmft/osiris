#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_FILE="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"
SCRIPT_NAME="$(SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"; printf "%s" "${SCRIPT_NAME%.*}")"

declare INCLUDE_DIR
declare -A INCLUDE_DIRS
declare INCLUDE_PATH
declare -a INCLUDE_PATHS
declare INCLUDE
declare -a INCLUDES

__help() {
	cat << __END
osiris - operating system installer running include scripts
Usage: osiris.sh [options] include...

Options:
  -c <file>         Add <file> to the config files to process.
  -i <directory>    Add <directory> to the include paths to search.
  -o <file>         Install to <file>; either a device or an image file.
  -p <phase>        Add <phase> to the phases to run.
  -r                Skip checking for root privileges.
  -s <step>         Add <step> to the steps to run; is run in all phases.
  -t <dir>          Use <dir> as the script's temp dir.
  -y                Auto-confirm with 'YES' to start installation.
  -h                Print this help message and exit.

Options starting with -c, -i, -p or -s can be used multiple times. They are
 processed in their given order.

If existing, then the 'include' directories in the current and the script's
 directory are automatically added last to the include paths to search.

If no phase is specified using -p, then the following phases are run:
  inittemp
  initoutput
  bootstrap
  initchroot
  runchroot
  donechroot
  finish
  doneoutput
  donetemp

If no step is specified using -s, then the following steps are run:
  before
  main
  after

All steps are run in all phases.

For bug reports, please visit:
 <https://github.com/wrzlbrmft/osiris/issues>
__END
}

__include() {
	local INCLUDE="$1"

	if [ -z "${INCLUDE_DIRS["${INCLUDE}"]}" ]; then
		local INCLUDE_DIR

		local INCLUDE_PATH
		for INCLUDE_PATH in "${INCLUDE_PATHS[@]}"; do
			if [ -d "${INCLUDE_PATH}/${INCLUDE}" ]; then
				INCLUDE_DIR="${INCLUDE_PATH}/${INCLUDE}"
			fi
		done

		if [ -z "${INCLUDE_DIR}" ]; then
			printf "fatal error: include not found ('%s')\n" "${INCLUDE}" >&2
			exit 1
		fi

		INCLUDE_DIRS["${INCLUDE}"]="${INCLUDE_DIR}"

		if [ -f "${INCLUDE_DIR}/include.conf" ]; then
			source "${INCLUDE_DIR}/include.conf"
		fi

		if [ -f "${INCLUDE_DIR}/include.lib.sh" ]; then
			source "${INCLUDE_DIR}/include.lib.sh"
		fi

		INCLUDES+=("${INCLUDE}")
	fi
}

__run() {
	local PHASE="$1"
	local STEP="$2"

	local INCLUDE_DIR
	local PHASE_FILE
	local FUNCTION

	local INCLUDE
	for INCLUDE in "${INCLUDES[@]}"; do
		INCLUDE_DIR="${INCLUDE_DIRS["${INCLUDE}"]}"
		PHASE_FILE="${INCLUDE_DIR}/${PHASE}.sh"

		if [ -f "${PHASE_FILE}" ]; then
			source "${PHASE_FILE}"

			FUNCTION="_$(printf "%s" "${INCLUDE}" | sed 's/\//_/g')_${PHASE}_${STEP}"
			if [ "function" == "$(type -t "${FUNCTION}")" ]; then
				"${FUNCTION}"
			fi
		fi
	done
}

# main

declare CONFIG_FILE
declare -a CONFIG_FILES
declare PHASE
declare -a PHASES
declare STEP
declare -a STEPS

while getopts :hc:i:o:p:rs:t:y OPT; do
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

		r)
			SKIP_ROOT_CHECK="1"
			;;

		s)
			STEP="${OPTARG}"
			STEPS+=("${STEP}")
			;;

		t)
			SCRIPT_TEMP_DIR="${OPTARG}"
			KEEP_SCRIPT_TEMP_DIR="1"
			;;

		y)
			AUTO_CONFIRM_YES="1"
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

				t)
					printf "missing temp dir" >&2
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
shift "$((OPTIND-1))"

if [ -z "$*" ]; then
	printf "fatal error: no include\n" >&2
	exit 1
fi

if [ -z "${SKIP_ROOT_CHECK}" ] && [ "root" != "${USER}" ]; then
	printf "fatal error: no root privileges ('%s')\n" "${USER}" >&2
	exit 1
fi

if [ -d "$(pwd)/include" ]; then
	INCLUDE_PATHS+=("$(pwd)/include")
fi

if [ -d "${SCRIPT_DIR}/include" ]; then
	INCLUDE_PATHS+=("${SCRIPT_DIR}/include")
fi

__include "osiris/internal/temp"
__include "osiris/internal/output"
__include "osiris/internal/chroot"

for INCLUDE in "$@"; do
	__include "${INCLUDE}"
done

for CONFIG_FILE in "${CONFIG_FILES[@]}"; do
	source "${CONFIG_FILE}"
done

if [ -z "${PHASES[@]}" ]; then
	PHASES=(inittemp initoutput bootstrap initchroot runchroot donechroot finish doneoutput donetemp)
fi

if [ -z "${STEPS[@]}" ]; then
	STEPS=(before main after)
fi

for PHASE in "${PHASES[@]}"; do
	for STEP in "${STEPS[@]}"; do
		__run "${PHASE}" "${STEP}"
	done
done

exit 0
