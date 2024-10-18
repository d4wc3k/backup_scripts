#!/bin/bash
## Backup functions
## EFI partition backup function
#
function BackupEFI()
{
	EFI_DEV=$(blkid | grep EFI | awk '{print $1}' | sed 's/://g')
	if [[ -z "${EFI_DEV}" ]]; then
		echo "Not EFI partition found - skipped"
	else
		echo $EFI_DEV
		partclone.vfat -c -s $EFI_DEV | gzip -c -9 > ./"${BACKUP_NAME}"/efi.img.gz
	fi
}
#
## WINMSR partition backup function
#
function BackupWINMSR()
{
	WINMSR_DEV=$(blkid | grep WINMSR | awk '{print $1}' | sed 's/://g')
	if [[ -z "${WINMSR_DEV}" ]]; then
		echo "Not WINMSR partition found - skipped"
	else
		echo $WINMSR_DEV
		partclone.dd -s $WINMSR_DEV | gzip -c -9 > ./"${BACKUP_NAME}"/winmsr.img.gz
	fi
}
## WINOS partition backup function
function BackupWINOS()
{
	WINOS_DEV=$(blkid | grep WINOS | awk '{print $1}' | sed 's/://g')
	if [[ -z "${WINOS_DEV}" ]]; then
		echo "Not WINOS partition found - skipped"
	else
		echo $WINOS_DEV
		partclone.ntfs -c -s $WINOS_DEV | gzip -c -9 > ./"${BACKUP_NAME}"/winos.img.gz
	fi
}
## WINREC partition backup function
function BackupWINREC()
{
	WINREC_DEV=$(blkid | grep WINREC | awk '{print $1}' | sed 's/://g')
	if [[ -z "${WINREC_DEV}" ]]; then
		echo "Not WINREC partition found - skipped"
	else
		echo $WINREC_DEV
		partclone.ntfs -c -s $WINREC_DEV | gzip -c -9 > ./"${BACKUP_NAME}"/winrec.img.gz
	fi
}
## WIND partition backup function
function BackupWINDATA()
{
	WINDATA_DEV=$(blkid | grep WINDATA | awk '{print $1}' | sed 's/://g')
	if [[ -z "${WINDATA_DEV}" ]]; then
		echo "Not WINDATA partition found - skipped"
	else
		echo $WINDATA_DEV
		partclone.ntfs -c -s $WINDATA_DEV | gzip -c -9 > ./"${BACKUP_NAME}"/windata.img.gz
	fi
}
## Main procedure
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
## Backup Name
read -p "Enter backup name: " BACKUP_NAME
if [[ -z "${BACKUP_NAME}" ]]; then
	echo "Empty backup name, exiting..."
	exit 1
else
	mkdir ./"${BACKUP_NAME}"
	# BackupEFI
	# BackupWINMSR
	# BackupWINOS
	# BackupWINREC
	# BackupWINDATA
fi
##

