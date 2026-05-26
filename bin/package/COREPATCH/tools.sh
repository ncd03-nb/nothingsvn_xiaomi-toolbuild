#!/usr/bin/env bash
# scripts/core/tools.sh

# Environment initialization and tool checks
init_env() {
  # Allow overriding from environment before calling init_env
  : "${TOOLS_DIR:=/home/runner/work/ZK_AUTO_BUILD/ZK_AUTO_BUILD/tools}"
  : "${WORK_DIR:=/home/runner/work/ZK_AUTO_BUILD/ZK_AUTO_BUILD}"
  : "${BACKUP_DIR:=${WORK_DIR}/backup}"
  mkdir -p "$BACKUP_DIR"
}

ensure_tools() {
  local HOME="/home/runner"
  # Checks for java, apktool.jar and 7z (optional)
  if ! command -v java > /dev/null 2>&1; then
    err "java not found in PATH"
    return 1
  fi

  if [ ! -f "${TOOLS_DIR}/apktool.jar" ]; then
    err "apktool.jar not found at ${TOOLS_DIR}/apktool.jar"
    return 1
  fi

  if ! command -v 7z > /dev/null 2>&1; then
    warn "7z not found in PATH — create_magisk_module will try to use zip if available"
  fi

  if ! command -v unzip > /dev/null 2>&1; then
    err "unzip not found in PATH"
    return 1
  fi

  return 0
}
