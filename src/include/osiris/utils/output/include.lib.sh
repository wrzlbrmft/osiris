#!/usr/bin/env bash
_osiris_utils_output__get_partition_device_files_mounted() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		findmnt -ln -o SOURCE | grep "^${DEVICE_FILE}"
	fi
}

_osiris_utils_output__get_partition_device_files() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		lsblk -lnp -o NAME -x NAME "${DEVICE_FILE}" | grep "^${DEVICE_FILE}" | grep -v "^${DEVICE_FILE}$"
	fi
}

_osiris_utils_output__create_file_path() {
	local FILE="$1"

	if [ -n "${FILE}" ]; then
		if [ ! -d "$(dirname "${FILE}")" ]; then
			mkdir -p "$(dirname "${FILE}")"
		fi
	fi
}

_osiris_utils_output__reset_file() {
	local FILE="$1"
	local SIZE="$2"

	if [ -z "${SIZE}" ]; then
		SIZE="1"
	fi

	if [ -n "${FILE}" ]; then
		_osiris_utils_output__create_file_path "${FILE}"

		dd if=/dev/zero of="${FILE}" bs=1M count="${SIZE}" status=progress
	fi
}

_osiris_utils_output__delete_partition() {
	local DEVICE_FILE="$1"

	if [ -n "${DEVICE_FILE}" ]; then
		_osiris_utils_output__reset_file "${DEVICE_FILE}"
	fi
}

_osiris_utils_output__delete_all_partitions() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		for PARTITION_DEVICE_FILE in "$(_osiris_utils_output__get_partition_device_files "${DEVICE_FILE}" | sort -r)"; do
			_osiris_utils_output__delete_partition "${PARTITION_DEVICE_FILE}"
		done

		partprobe
	fi
}

_osiris_utils_output__delete_partition_table() {
	local DEVICE_FILE="$1"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ]; then
		_osiris_utils_output__reset_file "${DEVICE_FILE}"
	fi
}

_osiris_utils_output__create_partition_table() {
	local PARTITION_TABLE_TYPE="$1"
	local DEVICE_FILE="$2"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${PARTITION_TABLE_TYPE}" ] && [ -n "${DEVICE_FILE}" ]; then
		parted -a optimal "${DEVICE_FILE}" mklabel "${PARTITION_TABLE_TYPE}"

		partprobe
	fi
}

_osiris_utils_output__create_partition() {
	local PARTITION_TYPE="$1"
	local PARTITION_SIZE="$2"
	local PARTITION_UNIT="$3"
	local DEVICE_FILE="$4"

	if [ -z "${DEVICE_FILE}" ]; then
		DEVICE_FILE="${OUTPUT_DEVICE_FILE}"
	fi

	if [ -n "${DEVICE_FILE}" ] && [ -n "${PARTITION_TYPE}" ] && [ "-1" != "${OUTPUT_PARTITION_START}" ]; then
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
}

_osiris_utils_output__create_image() {
	local IMAGE_FILE="$1"
	local IMAGE_SIZE="$2"

	if [ -z "${IMAGE_FILE}" ]; then
		IMAGE_FILE="${OUTPUT_IMAGE_FILE}"
	fi

	if [ -z "${IMAGE_SIZE}" ]; then
		IMAGE_SIZE="${OUTPUT_IMAGE_SIZE}"
	fi

	if [ -n "${IMAGE_FILE}" ] && [ -n "${IMAGE_SIZE}" ]; then
		_osiris_utils_output__reset_file "${IMAGE_FILE}" "${IMAGE_SIZE}"
	fi
}

_osiris_utils_output__init_device() {
	OUTPUT_DEVICE_FILE="$1"

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		OUTPUT_DEVICE_FILE="${OUTPUT_FILE}"
	fi

	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi

	if [ -n "$(_osiris_utils_output__get_partition_device_files_mounted "${OUTPUT_DEVICE_FILE}")" ]; then
		printf "fatal error: output device is currently mounted ('%s')\n" "${OUTPUT_DEVICE_FILE}" >&2
		exit 1
	fi

	_osiris_utils_output__delete_all_partitions "${OUTPUT_DEVICE_FILE}"
	_osiris_utils_output__delete_partition_table "${OUTPUT_DEVICE_FILE}"

	OUTPUT_TYPE="device"
}

_osiris_utils_output__init_image() {
	OUTPUT_IMAGE_FILE="$1"
	local IMAGE_SIZE="$2"

	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		OUTPUT_IMAGE_FILE="${OUTPUT_FILE}"
	fi

	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: no output image file\n" >&2
		exit 1
	fi

	if [ -f "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: output image file already exists ('%s')\n" "${OUTPUT_IMAGE_FILE}" >&2
		exit 1
	fi

	if [ -n "${IMAGE_SIZE}" ]; then
		OUTPUT_IMAGE_SIZE="${IMAGE_SIZE}"
	fi

	if [ -z "${OUTPUT_IMAGE_SIZE}" ]; then
		printf "fatal error: no output image size\n" >&2
		exit 1
	fi

	_osiris_utils_output__create_image "${OUTPUT_IMAGE_FILE}" "${OUTPUT_IMAGE_SIZE}"

	OUTPUT_DEVICE_FILE="$(losetup -f)"
	losetup -P "${OUTPUT_DEVICE_FILE}" "${OUTPUT_IMAGE_FILE}"

	OUTPUT_TYPE="image"
}

_osiris_utils_output__done_device() {
	if [ -z "${OUTPUT_DEVICE_FILE}" ]; then
		printf "fatal error: no output device file\n" >&2
		exit 1
	fi
}

_osiris_utils_output__done_image() {
	if [ -z "${OUTPUT_IMAGE_FILE}" ]; then
		printf "fatal error: no output image file\n" >&2
		exit 1
	fi

	losetup -d "${OUTPUT_DEVICE_FILE}"
}
