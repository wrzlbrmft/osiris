#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_FILE="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"
SCRIPT_NAME="$(SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"; printf "%s" "${SCRIPT_NAME%.*}")"

# main

exit 0
