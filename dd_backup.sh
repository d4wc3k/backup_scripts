#!/bin/bash

BACKUP_DEVICE="/dev/nvme0n1"
FILE_NAME="backup_nvme0n1.img.7z"
BLOCK_SIZE="4096"

dd if="${BACKUP_DEVICE}" conv=sync,noerror bs="${BLOCK_SIZE}" status=progress | 7z a -t7z "${FILE_NAME}" -si -m0=lzma2 -mx=9 -mfb=64 -md512m -mmt8
