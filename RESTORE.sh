#!/bin/bash
##############################################################################################################################################################################
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
	if [[ -f ${FILE_NAME} ]];
	then
		if [ "${FILE_SYSTEM}" = "raw" ];
		then
			## gzip compression
			# 
			# echo "Restoring raw image for $LABEL."
			# gzip -c -d "${FILE_NAME}" | partclone.dd -N -z 10485760 --source - -o "${DEV_PATH}"
			#
			## gzip with pigz compression
			#
			echo "Restoring raw image for partition with $LABEL label."
			pigz -d -c "${FILE_NAME}" | partclone.dd -N -z 10485760 --source - -o "${DEV_PATH}"
			#
		else
			## gzip compression
			#
			# echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			# gzip -c -d "${FILE_NAME}" | partclone.$FILE_SYSTEM -N-z 10485760 --source - -r -o  "${DEV_PATH}"
			#
			## gzip with pigz compression
			#
			echo "Restoring partclone image for partition with $LABEL label and ${FILE_SYSTEM} filesystem."
			pigz -d -c "${FILE_NAME}" | partclone.$FILE_SYSTEM -N -z 10485760 --source - -r -o  "${DEV_PATH}"
			#
		fi
	else
		echo "Backup file for $LABEL doesn't exists (skipping)."
		continue
	fi
	echo "################################################################################################################"
done
##############################################################################################################################################################################
