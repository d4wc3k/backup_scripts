#!/bin/bash
#
## DISKs devices names found in "/dev/disk/by-id/*"
# MAIN_DISK_NAME="nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M910268J"
# SECOND_DISK_NAME="nvme-Samsung_SSD_980_1TB_S649NJ0R214022Y"
#
## PARTITIONS LABELS
declare -A PARTITIONS=(["EFI"]="vfat" ["WINMSR"]="raw" ["WINOS"]="ntfs" ["WINREC"]="ntfs" ["WINDATA"]="ntfs" )
#
## Restore partition table (OPTIONAL)
# MAIN_DISK="/dev/disk/by-id/${MAIN_DISK_NAME}"
# dd if="${MAIN_DISK_NAME}_table.backup" of="${MAIN_DISK}" bs=512 status=progress
# sync
# gdisk "${MAIN_DISK}" 
#
## Get password for encryption ( optional )
# PASS_CRED=$(gpg --quiet --decrypt credentials.gpg)
#
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
for PART in "${!PARTITIONS[@]}"; 
do
	LABEL="${PART}"
	echo "Current partition label: ${LABEL}"
	FILE_SYSTEM="${PARTITIONS[$LABEL]}"
	echo "Current partition filesystem: ${FILE_SYSTEM}"
	echo "Processing partition with ${LABEL} label and ${FILE_SYSTEM} filesystem"
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
		if [ "${FILE_SYSTEM}" = "raw" ];
		then
			## 7z compression
			# echo "Restoring raw image for partition with $LABEL label."
			# 7z x -so "${FILE_NAME}" | partclone.dd -N -z 10485760 --source - -o "${DEV_PATH}"
			#
			## 7z compression and encryption
			# echo "Restoring raw image for partition with $LABEL label."
			# 7z x -so -p"${PASS_CRED}" "${FILE_NAME}" | partclone.dd -N -z 10485760 --source - -o "${DEV_PATH}"
			#
			## gzip compression
			# echo "Restoring raw image for $LABEL."
			# gzip -c -d "${FILE_NAME}" | partclone.dd -N -z 10485760 --source - -o "${DEV_PATH}"
			#
			## gzip with pigz compression
			echo "Restoring raw image for partition with $LABEL label."
			pigz -d -c "${FILE_NAME}" | partclone.dd -N -z 10485760 --source - -o "${DEV_PATH}"
			#
		else
			## 7z compression
			# echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			# 7z x -so "${FILE_NAME}" | partclone.$FILE_SYSTEM -N -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
			## 7z compression and encryption
			# echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			# 7z x -so -p"${PASS_CRED}"  "${FILE_NAME}" | partclone.$FILE_SYSTEM -N -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
			## gzip compression
			# echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			# gzip -c -d "${FILE_NAME}" | partclone.$FILE_SYSTEM -N-z 10485760 --source - -r -o  "${DEV_PATH}"
			#
			## gzip with pigz compression
			echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			pigz -d -c "${FILE_NAME}" | partclone.$FILE_SYSTEM -N -z 10485760 --source - -r -o  "${DEV_PATH}"
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
