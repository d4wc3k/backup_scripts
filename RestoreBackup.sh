#!/bin/bash
## EFI partition restore function
#
PARTITION_LABELS=("EFI" "WINMSR" "WINOS" "WINREC" "WINDATA")
function RestoreEFI()
{
	EFI_DEV=$(blkid | grep -i ${PARTITION_LABELS[0]} | grep vfat | awk '{print $1}' | sed 's/://g')
	if [ ! -z "${EFI_DEV}" ]; then
		echo "EFI partition device found."
		if [ -f "$BACKUP_NAME/efi.img.gz" ]; then
			echo "Backup image file for EFI partition found."
			gzip -c -d "$BACKUP_NAME/efi.img.gz" | partclone.vfat -r -o $EFI_DEV
		else
			echo "EFI Backup image file not found - exiting"
			exit 1
		fi
	else
		echo "EFI partition device not found - exiting."
		exit 1
	fi
}
## WIN MSR partition restore function
#
function RestoreWINMSR()
{
	WINMSR_DEV=$(blkid | grep -i ${PARTITION_LABELS[1]} | awk '{print $1}' | sed 's/://g')
	if [ ! -z "${WINMSR_DEV}" ]; then
		echo "WINMSR partition device found."
		if [ -f "$BACKUP_NAME/winmsr.img.gz" ]; then
			echo "Backup image file for WINMSR partition found."
			gzip -c -d "$BACKUP_NAME/winmsr.img.gz" | partclone.dd -o $WINMSR_DEV
		else
			echo "WINMSR Backup image file not found - exiting"
			exit 1
		fi
	else
		echo "WINMSR partition device not found - exiting."
		exit 1
	fi
}
## WINOS partition restore function
#
function RestoreWINOS()
{
	WINOS_DEV=$(blkid | grep -i ${PARTITION_LABELS[2]} | grep ntfs | awk '{print $1}' | sed 's/://g')
	if [ ! -z "${WINOS_DEV=}" ]; then
		echo "WINOS partition device found."
		if [ -f "$BACKUP_NAME/winos.img.gz" ]; then
			echo "Backup image file for WINOS partition found."
			gzip -c -d "$BACKUP_NAME/winos.img.gz" | partclone.ntfs -r -o $WINOS_DEV
		else
			echo "WINOS Backup image file not found - exiting"
			exit 1
		fi
	else
		echo "WINOS partition device not found - exiting."
		exit 1
	fi
}
#
## WINREC partition restore function
#
function RestoreWINREC()
{
	WINREC_DEV=$(blkid | grep -i ${PARTITION_LABELS[3]} | grep ntfs | awk '{print $1}' | sed 's/://g')
	if [ ! -z "${WINREC_DEV=}" ]; then
		echo "WINREC partition device found."
		if [ -f "$BACKUP_NAME/winrec.img.gz" ]; then
			echo "Backup image file for WINREC partition found."
			gzip -c -d "$BACKUP_NAME/winrec.img.gz" | partclone.ntfs -r -o $WINREC_DEV
		else
			echo "WINREC Backup image file not found - exiting"
			exit 1
		fi
	else
		echo "WINREC partition device not found - exiting."
		exit 1
	fi
}
#
## WINDATA partition restore function
#
function RestoreWINDATA()
{
	WINDATA_DEV=$(blkid | grep -i ${PARTITION_LABELS[4]} | grep ntfs | awk '{print $1}' | sed 's/://g')
	if [ ! -z "${WINDATA_DEV=}" ]; then
		echo "WINDATA partition device found."
		if [ -f "$BACKUP_NAME/windata.img.gz" ]; then
			echo "Backup image file for WINDATA partition found."
			gzip -c -d "$BACKUP_NAME/windata.img.gz" | partclone.ntfs -r -o $WINDATA_DEV
		else
			echo "WINDATA Backup image file not found - exiting"
			exit 1
		fi
	else
		echo "WINDATA partition device not found - exiting."
		exit 1
	fi
}
#
# Main procedure
## Checking required commands
#
REQUIRED_COMMANDS=("partclone.vfat" "partclone.dd" "partclone.ntfs" "partclone.ext2" "partclone.ext4" "gzip")
echo "Checking for required commands..."
for cmd in "${REQUIRED_COMMANDS[@]}"; do
	if ! command -v $cmd >/dev/null 2>&1; then
		echo "Missing command $cmd. Please install the corresponding package and rerun this script."
		exit 1
	fi
done
echo "All required commands are available."
#
## Read backup name
read -p "Enter backup name: " BACKUP_NAME
if [ -d $BACKUP_NAME ] && [ ! -z "${BACKUP_NAME}" ]; then
	echo "Backup directory found."
	RestoreEFI
	RestoreWINMSR
	RestoreWINOS
	RestoreWINREC
	RestoreWINDATA
else
	echo "Backup directory doesn't exist - please try again - exiting..."
	exit 1
fi
