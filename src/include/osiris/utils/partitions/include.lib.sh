#!/usr/bin/env bash
__get_partition_device_files() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		lsblk -lnp -o NAME -x NAME "${DEVICE_FILE}" | grep "^${DEVICE_FILE}" | grep -v "^${DEVICE_FILE}$"
	fi
}

__get_partition_device_files_count() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		local PARTITION_DEVICE_FILES=($(__get_partition_device_files "${DEVICE_FILE}"))

		printf "%s" "${#PARTITION_DEVICE_FILES[@]}"
	fi
}

__get_partition_device_file() {
	local PARTITION_NUM="$1"
	local DEVICE_FILE="$2"

	if [ -n "${PARTITION_NUM}" ]; then
		if [ -z "${DEVICE_FILE}" ]; then
			DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
		fi

		if [ -n "${DEVICE_FILE}" ]; then
			local PARTITION_DEVICE_FILES=($(__get_partition_device_files "${DEVICE_FILE}"))

			printf "%s" "${PARTITION_DEVICE_FILES["$((PARTITION_NUM-1))"]}"
		fi
	fi
}

__get_partition_device_file_last() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		printf "%s" "$(__get_partition_device_file 0 "${DEVICE_FILE}")"
	fi
}

__get_mounted_partition_device_files() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		findmnt -ln -o SOURCE | grep "^${DEVICE_FILE}"
	fi
}

__get_mounted_partition_device_files_count() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		local PARTITION_DEVICE_FILES=($(__get_mounted_partition_device_files "${DEVICE_FILE}"))

		printf "%s" "${#PARTITION_DEVICE_FILES[@]}"
	fi
}

__create_partition_table() {
	local PARTITION_TABLE_TYPE="$1"
	local DEVICE_FILE="$2"

	if [ -n "${PARTITION_TABLE_TYPE}" ]; then
		if [ -z "${DEVICE_FILE}" ]; then
			DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
		fi

		if [ -n "${DEVICE_FILE}" ]; then
			parted -a optimal "${DEVICE_FILE}" mklabel "${PARTITION_TABLE_TYPE}"

			partprobe
		fi
	fi
}

__delete_partition_table() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		__create_file "${DEVICE_FILE}"
	fi
}

__create_partition() {
	local PARTITION_TYPE="$1"
	local PARTITION_SIZE="$2"
	local PARTITION_UNIT="$3"
	local DEVICE_FILE="$4"

	if [ -n "${PARTITION_TYPE}" ]; then
		if [ -z "${DEVICE_FILE}" ]; then
			DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
		fi

		if [ -n "${DEVICE_FILE}" ] && [ "-1" != "${OUTPUT_PARTITION_START}" ]; then
			if [ -n "${PARTITION_UNIT}" ]; then
				OUTPUT_PARTITION_UNIT="${PARTITION_UNIT}"
			fi

			local PARTITION_START="${OUTPUT_PARTITION_START}${OUTPUT_PARTITION_UNIT}"

			if [ -n "${PARTITION_SIZE}" ]; then
				if [ "1" == "${OUTPUT_PARTITION_START}" ]; then
					OUTPUT_PARTITION_START="${PARTITION_SIZE}"
				else
					OUTPUT_PARTITION_START="$((OUTPUT_PARTITION_START+PARTITION_SIZE))"
				fi

				local PARTITION_END="${OUTPUT_PARTITION_START}${OUTPUT_PARTITION_UNIT}"
			else
				OUTPUT_PARTITION_START="-1"

				local PARTITION_END="100%"
			fi

			parted -a optimal "${DEVICE_FILE}" mkpart primary "${PARTITION_TYPE}" "${PARTITION_START}" "${PARTITION_END}"

			partprobe
		fi
	fi
}

__delete_partition() {
	local DEVICE_FILE="$1"

	if [ -n "${DEVICE_FILE}" ]; then
		__create_file "${DEVICE_FILE}"
	fi
}

__delete_all_partitions() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		for PARTITION_DEVICE_FILE in $(__get_partition_device_files "${DEVICE_FILE}" | sort -r); do
			__delete_partition "${PARTITION_DEVICE_FILE}"
		done

		partprobe
	fi
}

__update_partition_flag() {
	local STATE="$1"
	local PARTITION_FLAG="$2"
	local PARTITION_NUM="$3"
	local DEVICE_FILE="$4"

	if [ -n "${STATE}" ] && [ -n "${PARTITION_FLAG}" ]; then
		if [ -z "${DEVICE_FILE}" ]; then
			DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
		fi

		if [ -n "${DEVICE_FILE}" ]; then
			if [ -z "${PARTITION_NUM}" ]; then
				PARTITION_NUM="$(__get_partition_device_files_count "${DEVICE_FILE}")"
			fi

			case "${STATE}" in
				set)
					parted -a optimal "${DEVICE_FILE}" set "${PARTITION_NUM}" "${PARTITION_FLAG}" on
					;;

				clear)
					parted -a optimal "${DEVICE_FILE}" set "${PARTITION_NUM}" "${PARTITION_FLAG}" off
					;;
			esac

			partprobe
		fi
	fi
}

__set_partition_flag() {
	local PARTITION_FLAG="$1"
	local PARTITION_NUM="$2"
	local DEVICE_FILE="$3"

	__update_partition_flag set "${PARTITION_FLAG}" "${PARTITION_NUM}" "${DEVICE_FILE}"
}

__clear_partition_flag() {
	local PARTITION_FLAG="$1"
	local PARTITION_NUM="$2"
	local DEVICE_FILE="$3"

	__update_partition_flag clear "${PARTITION_FLAG}" "${PARTITION_NUM}" "${DEVICE_FILE}"
}
