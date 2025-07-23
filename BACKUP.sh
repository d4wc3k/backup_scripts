#!/bin/bash
#
## DISKs devices names found in "/dev/disk/by-id/*"
MAIN_DISK_NAME="nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M910268J"
# SECOND_DISK_NAME="nvme-Samsung_SSD_980_1TB_S649NJ0R214022Y"
#
## Partitions for backup
declare -A PARTITIONS=(["EFI"]="vfat" ["WINMSR"]="raw" ["WINOS"]="ntfs" ["WINREC"]="ntfs" ["WINDATA"]="ntfs" )
#
## Get password for encryption ( optional )
# PASS_CRED=$(gpg --quiet --decrypt credentials.gpg)
#
## LUKS encrypted partition labels ( optional )
#
# MAIN_CRYPT_LABEL="rcrypt"
# SECOND_CRYPT_LABEL="dcrypt"
# LVM_DECRYPTED_NAME="lvm_unencrypted"
# VG_NAME="vg"
#
## MAIN
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
	if [ "${FILE_SYSTEM}" = "raw" ];
	then
		## 7z compression
		# echo "Creation raw image for partition with  ${LABEL} label with 7zip compression tool"
		# partclone.dd -N -z 10485760  -s "${DEV_PATH}" --output - | 7z a -t7z "${FILE_NAME}" -si -m0=lzma2 -mx=5 -mfb=64 -md512m -mmt8
		#
		## 7z compression and encryption
		# echo "Creation raw image for partition with  ${LABEL} label with 7zip (encrypted) compression tool"
		# partclone.dd -N -z 10485760  -s "${DEV_PATH}" --output - | 7z a -t7z -mhe=on -p"${PASS_CRED}" "${FILE_NAME}" -si -m0=lzma2 -mx=5 -mfb=64 -md512m -mmt8
		#
		## gzip compression
		# echo "Creation raw image for partition with  ${LABEL} label with gz compression tool"
		# partclone.dd -N -z 10485760  -s "${DEV_PATH}" --output - | gzip -c -6 > "${FILE_NAME}"
		#
		## gzip with pigz compression
		echo "Creation raw image for partition with  ${LABEL} label with pigz compression tool"
		partclone.dd -N -z 10485760  -s "${DEV_PATH}" --output - | pigz -c --fast -b 1024 --rsyncable > "${FILE_NAME}"
		#
	else
		## 7z compression
		# echo "Creation partclone image for partition with  ${LABEL} label with 7zip compression tool"
		# partclone.$FILE_SYSTEM -N -z 10485760  -c -s "${DEV_PATH}" --output - | 7z a -t7z  "${FILE_NAME}" -si -m0=lzma2 -mx=5 -mfb=64 -md512m -mmt8
		#
		## 7z compression and encryption
		# echo "Creation partclone image for partition with  ${LABEL} label with 7zip (encrypted) compression tool"
		# partclone.$FILE_SYSTEM -N -z 10485760  -c -s "${DEV_PATH}" --output - | 7z a -t7z -mhe=on -p"${PASS_CRED}" "${FILE_NAME}" -si -m0=lzma2 -mx=5 -mfb=64 -md512m -mmt8
		#
		## gzip compression
		# echo "Creation partclone image for partition with  ${LABEL} label with gz compression tool"
		## partclone.$FILE_SYSTEM -N -z 10485760  -c -s "${DEV_PATH}" --output - | gzip -c -6 > "${FILE_NAME}"
		#
		## gzip with pigz compression
		echo "Creation partclone image for partition with  ${LABEL} label with "${FILE_SYSTEM}" filesystem and pigz compression tool"
		partclone.$FILE_SYSTEM -N -z 10485760  -c -s "${DEV_PATH}" --output - | pigz -c --fast -b 1024 --rsyncable > "${FILE_NAME}"
		#
	fi
	echo "################################################################################################################"
	echo "################################################################################################################"
	echo "################################################################################################################"
	chown 1000:1000 "${FILE_NAME}"
done
################################################################################################################
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
################################################################################################################
#
## Backup LVM metadata configuration (OPTIONAL)
#
# MAIN_CRYPT_DEV="/dev/disk/by-label/${MAIN_CRYPT_LABEL}"
# SECOND_CRYPT_DEV="/dev/disk/by-label/${SECOND_CRYPT_LABEL}"
# LVM_DEVICE="/dev/mapper/${LVM_DECRYPTED_NAME}"
#
## backup PARTUUID and UUIDs of LVM and encrypted partitions (OPTIONAL)
# echo "Backup PARTUUIDs and UUID for LUKS/LVM..."
# blkid -s PARTUUID -o value "${MAIN_CRYPT_DEV}" > "${MAIN_CRYPT_LABEL}_PARTUUID.txt"
# blkid -s PARTUUID -o value "${SECOND_CRYPT_DEV}" > "${SECOND_CRYPT_LABEL}_PARTUUID.txt"
# blkid -s UUID -o value "${MAIN_CRYPT_DEV}" > "${MAIN_CRYPT_LABEL}_UUID.txt"
# blkid -s UUID -o value "${SECOND_CRYPT_DEV}" > "${SECOND_CRYPT_LABEL}_UUID.txt"
# blkid -s UUID -o value "${LVM_DEVICE}" > "${LVM_DECRYPTED_NAME}_UUID.txt"
# chown 1000:1000 *.txt
#
## backup luks headers (OPTIONAL)
#
# echo "Backup LUKS header for main encrypted partition..."
# cryptsetup luksHeaderBackup "${MAIN_CRYPT_DEV}" --header-backup-file "${MAIN_CRYPT_LABEL}_header_backup"
# gpg --symmetric --output "${MAIN_CRYPT_LABEL}_header_backup.gpg" "${MAIN_CRYPT_LABEL}_header_backup"
# shred --iterations=3 --zero --remove=wipesync "${MAIN_CRYPT_LABEL}_header_backup"
#
# echo "Backup LUKS header for second encrypted partition..."
# cryptsetup luksHeaderBackup "${SECOND_CRYPT_DEV}" --header-backup-file "${SECOND_CRYPT_LABEL}_header_backup"
# gpg --symmetric --output "${SECOND_CRYPT_LABEL}_header_backup.gpg" "${SECOND_CRYPT_LABEL}_header_backup"
# shred --iterations=3 --zero --remove=wipesync "${SECOND_CRYPT_LABEL}_header_backup"
# chown 1000:1000 *.gpg
#
## backup volume group metadata (OPTIONAL)
#
# echo "Backup volume group metadata..."
# vgcfgbackup -f "${VG_NAME}_METADATA.backup" "${VG_NAME}"
# chown 1000:1000 "${VG_NAME}_METADATA.backup"
#
################################################################################################################
