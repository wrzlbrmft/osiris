#!/usr/bin/env bash
__mount() {
	local ID="$1"
	local DEVICE_FILE="$2"
	local MOUNT_DIR="$3"
}

__unmount() {
	local ID="$1"
}

__unmount_all() {
	local _
}
