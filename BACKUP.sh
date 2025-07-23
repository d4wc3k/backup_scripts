#!/bin/bash
##############################################################################################################################################################################
#
## DISKs devices names found in "/dev/disk/by-id/*"
MAIN_DISK_NAME="nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M910268J"
# SECOND_DISK_NAME="nvme-Samsung_SSD_980_1TB_S649NJ0R214022Y"
#
## Partitions for backup
#
declare -A PARTITIONS=(["EFI"]="vfat" ["WINMSR"]="raw" ["WINOS"]="ntfs" ["WINREC"]="ntfs" ["WINDATA"]="ntfs" )
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
	FILE_NAME="$(echo ${LABEL} | tr '[:upper:]' '[:lower:]').img.gz"
	#
	if [ "${FILE_SYSTEM}" = "raw" ];
	then
		## gzip compression
		#
		# echo "Creation raw image for partition with  ${LABEL} label with gz compression tool"
		# partclone.dd -N -z 10485760  -s "${DEV_PATH}" --output - | gzip -c -6 > "${FILE_NAME}"
		#
		## gzip with pigz compression
		#
		echo "Creation raw image for partition with  ${LABEL} label with pigz compression tool"
		partclone.dd -N -z 10485760  -s "${DEV_PATH}" --output - | pigz -c --fast -b 1024 --rsyncable > "${FILE_NAME}"
		#
	else
		## gzip compression
		#
		# echo "Creation partclone image for partition with  ${LABEL} label with gz compression tool"
		# partclone.$FILE_SYSTEM -N -z 10485760  -c -s "${DEV_PATH}" --output - | gzip -c -6 > "${FILE_NAME}"
		#
		## gzip with pigz compression
		#
		echo "Creation partclone image for partition with  ${LABEL} label with "${FILE_SYSTEM}" filesystem and pigz compression tool"
		partclone.$FILE_SYSTEM  -N  -z 10485760  -c -s "${DEV_PATH}" --output - | pigz -c --fast -b 1024 --rsyncable > "${FILE_NAME}"
		#
	fi
	chown 1000:1000 *.gz
done
##############################################################################################################################################################################
## BACKUP of GPT Partition table
## MAIN DISK
#
echo "Backup main partition table..."
MAIN_DISK="/dev/disk/by-id/${MAIN_DISK_NAME}"
dd if=${MAIN_DISK} of="${MAIN_DISK_NAME}_table.backup" bs=512 count=34 status=progress
sfdisk --dump "${MAIN_DISK}" > "${MAIN_DISK_NAME}_dump.txt"
#
## SECOND DISK
#
# echo "Backup second partition table..."
# SECOND_DISK="/dev/disk/by-id/${SECOND_DISK_NAME}"
# dd if=${SECOND_DISK} of="${SECOND_DISK_NAME}_table.backup" bs=512 count=34 status=progress
# sfdisk --dump "${SECOND_DISK}" > "${SECOND_DISK_NAME}_dump.txt"
## 
echo "Syncing..."
sync
chown 1000:1000 *_table.backup
chown 1000:1000 *_dump.txt
#
##############################################################################################################################################################################
