#!/bin/bash
#
## PARTITIONS LABELS
PARTITION_LABELS=("EFI" "WINMSR" "WINOS" "WINREC")
##
## MAIN 
################################################################################################################
## OPTIONAL restore partitions table with dd
#
# MAIN_DISK="/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M910268J"
# TABLE_BACKUP_FILE_NAME="$(basename ${MAIN_DISK})_table.backup"
# dd if="${TABLE_BACKUP_FILE_NAME}" of="${MAIN_DISK}" bs=512 status=progress && sync
#
################################################################################################################
## OPTIONAL restore LVM_information
################################################################################################################
#
# LVM_DEVICE="/dev/nvme1n1p6"
# VG_NAME="vg"
# UUID="xyz"
# pvcreate --uuid "${UUID}" --norestorefile "${LVM_DEVICE}"
# vgcfgrestore -f vg_backup "${VG_NAME}"
#
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
	if [[ -f ${FILE_NAME} ]];
	then
		FS_TYPE=$(blkid -s TYPE -o value ${DEV_PATH})
		if [ -z "${FS_TYPE}" ] || [ "${FS_TYPE}" = "swap" ];
		then
			## 7z compression
			# 7z x -so "${FILE_NAME}" | partclone.dd -z 10485760 --source - -o "${DEV_PATH}"
			#
			## gzip compression
			# gzip -c -d "${FILE_NAME}" | partclone.dd -z 10485760 --source - -o "${DEV_PATH}"
			#
			## gzip with pigz compression
			pigz -d -c "${FILE_NAME}" | partclone.dd -z 10485760 --source - -o "${DEV_PATH}"
			#
		else
			## 7z compression
			# 7z x -so "${FILE_NAME}" | partclone.$FS_TYPE -z 10485760 --source - -r -o  "${DEV_PATH}"
			## gzip compression
			# gzip -c -d "${FILE_NAME}" | partclone.$FS_TYPE -z 10485760 --source - -r -o  "${DEV_PATH}"
			## gzip with pigz compression
			pigz -d -c "${FILE_NAME}" | partclone.$FS_TYPE -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
		fi
	else
		echo "Backup file for $LABEL doesn't exists (skipping)."
		continue
	fi
	echo "################################################################################################################"
	echo "################################################################################################################"
	echo "################################################################################################################"
done
