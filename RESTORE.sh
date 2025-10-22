#!/bin/bash
##############################################################################################################################################################################
## Restoring partition tables
## Uncomment if there is needed recreation of disk layouts
#
# MAIN_DISK_NAME="nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M910268J"
# MAIN_DISK="/dev/disk/by-id/${MAIN_DISK_NAME}"
# dd if="main_table.bin" of="${MAIN_DISK}" bs=512 status=progress && sync
# gdisk "${MAIN_DISK}"
#
# SECOND_DISK_NAME="nvme-Samsung_SSD_980_1TB_S649NJ0R214022Y"
# SECOND_DISK="/dev/disk/by-id/${SECOND_DISK_NAME}"
# dd if="second_table.bin" of="${SECOND_DISK}" bs=512 status=progress && sync
# gdisk "${SECOND_DISK}"
##############################################################################################################################################################################
#
## Partitions for backup
#
# PARTLABEL
declare -A PARTITIONS=(["EFI"]="vfat" ["WINMSR"]="raw" ["WINOS"]="ntfs" ["WINREC"]="ntfs" ["WINDATA"]="ntfs" )
# PARTLABEL + LABEL
# declare -A PARTITIONS=(["EFI"]="vfat" ["WINMSR"]="raw" ["WinOS"]="ntfs" ["WinRec"]="ntfs" ["WinData"]="ntfs" )
#
##############################################################################################################################################################################
## MAIN 
#
for PART in "${!PARTITIONS[@]}"; 
do
	echo "################################################################################################################"
	LABEL="${PART}"
	FILE_SYSTEM="${PARTITIONS[$LABEL]}"
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
	#
	## gzip compression(gzip/pigz)
	#
	# FILE_NAME="$(echo ${LABEL} | tr '[:upper:]' '[:lower:]').img.gz"
	#
	## 7zip compression
	#
	# FILE_NAME="$(echo ${LABEL} | tr '[:upper:]' '[:lower:]').img.7z"
	#
	## rar compression
	FILE_NAME="$(echo ${LABEL} | tr '[:upper:]' '[:lower:]').img.rar"
	#
	if [[ -f ${FILE_NAME} ]];
	then
		if [ "${FILE_SYSTEM}" = "raw" ];
		then
			## gzip compression
			# 
			# echo "Restoring raw image for $LABEL."
			# gzip -c -d "${FILE_NAME}" | partclone.dd -z 10485760 --source - -o "${DEV_PATH}"
			#
			## gzip with pigz compression
			#
			# echo "Restoring raw image for partition with $LABEL label."
			# pigz -d -c "${FILE_NAME}" | partclone.dd -z 10485760 --source - -o "${DEV_PATH}"
			#
			## 7zip compression
			#
			# echo "Restoring raw image for partition with $LABEL label."
			# 7z x -bd -so "${FILE_NAME}" | partclone.dd -z 10485760 --source - -o "${DEV_PATH}"
			#
			## rar compression
			#
			echo "Restoring raw image for partition with $LABEL label."
			rar p "${FILE_NAME}" | partclone.dd -z 10485760 --source - -o "${DEV_PATH}"
			#
		else
			## gzip compression
			#
			# echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			# gzip -c -d "${FILE_NAME}" | partclone.$FILE_SYSTEM -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
			## gzip with pigz compression
			#
			# echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			# pigz -d -c "${FILE_NAME}" | partclone.$FILE_SYSTEM -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
			## 7zip compression
			#
			# echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			# 7z x -bd -so "${FILE_NAME}" | partclone.$FILE_SYSTEM -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
			## rar compression
			#
			echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			rar p "${FILE_NAME}" | partclone.$FILE_SYSTEM -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
		fi
	else
		echo "Backup file for $LABEL doesn't exists (skipping)."
		continue
	fi
	echo "################################################################################################################"
done
##############################################################################################################################################################################
