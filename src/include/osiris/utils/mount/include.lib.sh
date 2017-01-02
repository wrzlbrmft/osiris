#!/usr/bin/env bash
__mount() {
	local LABEL="$1"
	local MOUNT_DIR="$2"
	local DEVICE_FILE="$3"
}

__unmount() {
	local LABEL="$1"
}

__unmount_all() {
	local _
}
