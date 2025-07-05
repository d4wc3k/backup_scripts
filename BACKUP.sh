#!/bin/bash
#
## PARTITIONS LABELS for backup
PARTITION_LABELS=("EFI" "WINMSR" "WINOS" "WINREC" "swap")
## Main disk
MAIN_DISK="/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M910268J"
#
## MAIN
################################################################################################################
for LABEL in "${PARTITION_LABELS[@]}"; 
do
	echo "Processing ${LABEL} label."
	PARTLABEL_DEV="/dev/disk/by-partlabel/${LABEL}"
	if [[ -h "${PARTLABEL_DEV}" ]];
	then
		DEV_PATH=${PARTLABEL_DEV}
		echo "Device file for ${LABEL} label has been found."
	else
		LABEL_DEV="/dev/disk/by-label/${LABEL}"
		if [[ -h "${LABEL_DEV}" ]];
		then
			DEV_PATH=${LABEL_DEV}
			echo "Device file for ${LABEL} label has been found."
		else
			echo "Device file for ${LABEL} label has not been found (skipping)."
			continue
		fi
	fi
	## 7z compression
	# FILE_NAME="$(echo ${LABEL} | tr '[:upper:]' '[:lower:]').img.7z"
	#
	## gzip compression(gzip/pigz)
	FILE_NAME="$(echo ${LABEL} | tr '[:upper:]' '[:lower:]').img.gz"
	#
	FS_TYPE=$(blkid -s TYPE -o value ${DEV_PATH})
	if [ -z "${FS_TYPE}" ] || [ "${FS_TYPE}" = "swap" ];
	then
		## 7z compression
		# partclone.dd  -z 10485760  -s "${DEV_PATH}" --output - | 7z a -t7z "${FILE_NAME}" -si -m0=lzma2 -mx=1 -mfb=64 -md512m -mmt8
		#
		## gzip compression
		# partclone.dd  -z 10485760  -s "${DEV_PATH}" --output - | gzip -c -6 > "${FILE_NAME}"
		#
		## gzip with pigz compression
		partclone.dd  -z 10485760  -s "${DEV_PATH}" --output - | pigz -c --fast -b 1024 --rsyncable > "${FILE_NAME}"
		#
	else
		## 7z compression
		# partclone.$FS_TYPE -z 10485760  -c -s "${DEV_PATH}" --output - | 7z a -t7z "${FILE_NAME}" -si -m0=lzma2 -mx=1 -mfb=64 -md512m -mmt8
		#
		## gzip compression
		## partclone.$FS_TYPE -z 10485760  -c -s "${DEV_PATH}" --output - | gzip -c -6 > "${FILE_NAME}"
		#
		## gzip with pigz compression
		partclone.$FS_TYPE -z 10485760  -c -s "${DEV_PATH}" --output - | pigz -c --fast -b 1024 --rsyncable > "${FILE_NAME}"
		#
	fi
	echo "################################################################################################################"
	echo "################################################################################################################"
	echo "################################################################################################################"
	chown 1000:1000 "${FILE_NAME}"
done
################################################################################################################
## BACKUP of GPT Partition table
#
TABLE_BACKUP_FILE_NAME="$(basename ${MAIN_DISK})_table.backup"
dd if=${MAIN_DISK} of="${TABLE_BACKUP_FILE_NAME}" bs=512 count=34 status=progress && sync
chown 1000:1000 ${TABLE_BACKUP_FILE_NAME}
#
################################################################################################################
#
## Backup LVM metadata configuration (OPTIONAL)
# LVM_DEVICE="/dev/nvme1n1p6"
# VG_NAME="vg"
# pvdisplay "${LVM_DEVICE}" | grep UUID > PV_UUID.txt
# vgcfgbackup -f VG_METADATA.backup "${VG_NAME}"
# chown 1000:1000 PV_UUID.txt
# chown 1000:1000 VG_METADATA.backup
#
################################################################################################################
