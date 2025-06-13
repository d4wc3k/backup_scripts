#!/bin/bash
#
## configs
set -o errexit
set -o nounset
set -o pipefail
#
## VARs
readonly SOURCE_DIR="${HOME}/DataForBackup"
readonly BACKUP_DIR="${HOME}/BackupDir"
readonly BACKUP_NAME="$(date '+%Y_%m_%d_%H_%M_%S')"
readonly BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"
# readonly LATEST_LINK="${BACKUP_DIR}/latest"
#
if [ -f "${BACKUP_DIR}/latest_backup_dir.txt" ]
then
	echo "Last backup information was found"
	LAST_BACKUP_NAME=$(cat "${BACKUP_DIR}/latest_backup_dir.txt")
	if [ -d "${BACKUP_DIR}/${LAST_BACKUP_NAME}" ]
	then
		echo "Last backup directory has been found"
		LAST_BACKUP_DIR="${BACKUP_DIR}/${LAST_BACKUP_NAME}"
		echo "Creating incremental backup"
		rsync -av --delete "${SOURCE_DIR}/" --link-dest "${LAST_BACKUP_DIR}" "${BACKUP_PATH}"
		echo "${BACKUP_NAME}" > "${BACKUP_DIR}/latest_backup_dir.txt"

	else
		echo "Last backup directory has been not found"
	fi
else
	echo "Last backup information was not found"
	echo "Creating full backup"
	rsync -av --delete "${SOURCE_DIR}/" "${BACKUP_PATH}"
	echo "${BACKUP_NAME}" > "${BACKUP_DIR}/latest_backup_dir.txt"
fi
#
