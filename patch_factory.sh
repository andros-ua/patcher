#!/bin/sh
#
# patch_factory.sh — 55-byte patcher for COMFAST CF-WR632AX Wi-Fi EEPROM
# Usage: ./patch_factory.sh
#
# Copyright (C) 2026  Andrii Kuiukov
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# SPDX-License-Identifier: GPL-2.0-only

. /lib/functions.sh

VERSION="v3.3.3"

# Set the MTD partition label
MTD_LABEL="Factory"

# PATCH TABLE: hex_offset hex_byte (55 entries)
PATCHES="
0x0000024C 0xA4
0x0000024D 0xA6
0x0000024E 0xA6
0x0000024F 0xA6
0x00000250 0xA3
0x00000251 0x91
0x00000253 0x91
0x00000255 0x91
0x00000257 0x91
0x00000259 0x89
0x00000270 0x0C
0x00000495 0xC2
0x00000496 0xC2
0x00000497 0xC2
0x00000498 0xC0
0x00000499 0xC1
0x0000049A 0xC1
0x000004A1 0x81
0x000004A2 0x81
0x000004A3 0x81
0x000004A4 0x81
0x000004A5 0x81
0x000004A6 0xC1
0x000004A7 0x81
0x000004A8 0x81
0x000004A9 0xC1
0x000004AA 0xC1
0x000004AB 0xC1
0x000004AC 0x81
0x000004AD 0xC0
0x000004AE 0xC0
0x000004AF 0xC1
0x000004B0 0xC1
0x000004B1 0xC1
0x000004B2 0xC1
0x000004B3 0xC1
0x000004B4 0xC1
0x000004B5 0x83
0x000004B6 0x83
0x000004B7 0x83
0x000004B8 0x83
0x000004B9 0x83
0x000004BA 0x83
0x000004BB 0x83
0x000004BC 0x83
0x000004BD 0x81
0x000004BE 0x81
0x000004BF 0x80
0x00000991 0xB8
0x00000995 0xB8
0x00000999 0xCA
0x000009A0 0x01
0x000009A6 0xC4
0x000009A8 0xBB
0x000009AA 0x87
"
###############################################

# Function to print an error message and exit with a non-zero status
log_exit() {
	printf "\n\n$@\n\n"
	exit 1
}

# Function to loop through the patches and apply or verify them based on the mode
loop_patches () {
	local mode="$1" # Get the mode (write or verify) from the function argument
	local target="$2" # Get the target file from the function argument
	local offset="" # Initialize the offset variable to an empty string
	local value="" # Initialize the value variable to an empty string
	local old_value="" # Initialize the old value variable to an empty string
	local dec_off="" # Initialize the decimal offset variable to an empty string

	# Loop through each token in the PATCHES variable
	for token in $PATCHES; do
		# Check if the token is an offset or a value
		if [ -z "$offset" ]; then
			# The token is an offset, so store it for the next iteration
			offset="$token"
		else
			# The token is a value, so apply the patch
			value="$token"
			# Read the current byte value at the offset before patching
			old_value="0x$(hexdump -s "$offset" -n 1 -e '"%02X"' "$target")"
			if [ "$old_value" = "$value" ]; then
				case "$mode" in
					write)
						# The current value is the same as the new value, so skip this patch
						printf "\n\e[0;34m[SKIP]\e[0m %s: \e[0;33m%s\e[0m \e[0;34m=\e[0m \e[0;33m%s\e[0m" "$offset" "$old_value" "$value"
						SKIPPED=$((SKIPPED + 1))
						;;
					verify)
						# The current value is the same as the expected value, so print a success message
						printf "\n\e[0;32m[PASS]\e[0m %s: \e[0;33m%s\e[0m \e[0;34m=\e[0m \e[0;33m%s\e[0m" "$offset" "$old_value" "$value"
						;;
				esac
			else
				case "$mode" in
					write)
						# The current value is different from the new value, so apply the patch
						write_patch "$target" "$offset" "$value" "$old_value"
						;;
					verify)
						# The current value is different from the expected value, so print an error message
						printf "\n\e[0;31m[WARN]\e[0m %s: \e[0;33m%s\e[0m \e[0;34m<>\e[0m \e[0;33m%s\e[0m" "$offset" "$value" "$old_value"
						FAIL=$((FAIL + 1))
						;;
				esac
			fi
			offset="" # Reset the offset variable for the next iteration
		fi
	done
}

# Function to write a patch to the target file
write_patch() {
	local target="$1" # Get the target file from the function argument
	local offset="$2" # Get the hexadecimal offset from the function argument
	local value="$3" # Get the new value to be written from the function argument
	local old_value="$4" # Get the old value before patching from the function argument
	local current_value="" # Initialize the current value variable to an empty string
	local dec_off="" # Initialize the decimal offset variable to an empty string

	# Convert the hexadecimal offset to decimal for the dd command
	dec_off=$(printf '%d' "$offset")

	# Use printf to convert the hexadecimal value to a byte and write it to the target file at the specified offset using dd
	printf "\\$(printf '%03o' "$value")" \
		| dd of="$target" bs=1 seek="$dec_off" count=1 conv=notrunc 2>/dev/null
	# Check if the dd command was successful
	if [ $? -eq 0 ]; then
		# Read the current byte value at the offset after patching
		current_value="0x$(hexdump -s "$offset" -n 1 -e '"%02X"' "$target")"

		# Compare the current value with the expected value
		if [ $current_value = $value ]; then
			# The patch was applied successfully, so print a success message
			printf "\n\e[0;32m[OK]\e[0m %s: \e[0;33m%s\e[0m \e[0;32m->\e[0m \e[0;33m%s\e[0m" "$offset" "$old_value" "$value"
			COUNT=$((COUNT + 1)) # Increment the count of successful patches
		else
			# The patch was not applied correctly, so print an error message
			printf "\n\e[0;31m[ERR]\e[0m %s: \e[0;33m%s\e[0m \e[0;31m<>\e[0m \e[0;33m%s\e[0m" "$offset" "$value" "$current_value"
			FAIL=$((FAIL + 1)) # Increment the count of failed patches
		fi
	# The dd command failed, so print an error message
	else
		printf "\n\e[0;31m[ERR]\e[0m %s: \e[0;33m%s\e[0m \e[0;31m->\e[0m \e[0;33m%s\e[0m" "$offset" "$old_value" "$value"
		FAIL=$((FAIL + 1)) # Increment the count of failed patches
	fi
}

printf "\n+-------------------------------------------------------------+"
printf "\n|     COMFAST CF-WR632AX Wi-Fi EEPROM Patcher $VERSION          |"
printf "\n+-------------------------------------------------------------+"

# Check if the MTD partition exists and get its index
MTD_IDX=$(find_mtd_index "$MTD_LABEL")
if [ -z "$MTD_IDX" ]; then
    log_exit "Error: MTD partition '$MTD_LABEL' not found."
fi

# Set the MTD device path
MTD_DEV="/dev/mtd${MTD_IDX}"

# Get the erase block size of the MTD partition
EBS=$(cat /sys/class/mtd/mtd${MTD_IDX}/erasesize)

# Set the target file name
TARGET="/tmp/${MTD_LABEL}.bin"

# Set a trap to clean up the temporary file and backup file on exit
trap 'rm -f "$TARGET"' EXIT

# Dump the factory partition to a temporary file using dd
dd if="${MTD_DEV}ro" of="$TARGET" bs="$EBS" count=1 2>/dev/null && \
	printf "\n\nDumped $MTD_DEV to $TARGET." || {
    log_exit "Error: failed to dump $MTD_LABEL."
}

# Create a backup of the target file
cp "$TARGET" "${TARGET}.backup" && printf "\n\nBackup created: ${TARGET}.backup" || {
	log_exit "Error: failed to create backup."
}

# Check the magic number
MAGIC=$(hexdump -v -n 2 -e '"%02X"' "$TARGET")
# Check if the magic number is correct
if [ "$MAGIC" != "7981" ]; then
	log_exit "Error: $TARGET doesn't contain EEPROM"
fi

# Read the TSSI byte from the target file
TSSI=$(hexdump -s "0x09A0" -n 1 -e '"%02X"' "$TARGET")
# Check if the TSSI byte is 0x00, which indicates the critical flaw with closed-loop PA power control
if [ "$TSSI" = "00" ]; then
	printf "\n\nEEPROM has critical flaw with closed-loop PA power control."
	printf "\nPatching is required to fix the issue."
else
	printf "\n\nIt seems EEPROM is already patched. Continuing anyway..."
fi

# Initialize counters for failed, successful, and skipped patches
FAIL=0; COUNT=0; SKIPPED=0

printf "\n\nVerifying $MTD_LABEL ($MTD_DEV) dump:"
printf "\n---------------------------------------------------------------"
# Verify the patches by reading the factory partition and comparing the values
loop_patches verify "$TARGET"
if [ "$FAIL" -gt 0 ]; then
	printf "\n\nApplying patches is required.\n\nProceeding..."
else
	log_exit "${MTD_LABEL} (${MTD_DEV}) is already patched."
fi

# Reset the counter for failed
FAIL=0

printf "\n\nPatching ${TARGET}:"
printf "\n---------------------------------------------------------------"
# Loop through each patch in the PATCHES variable
loop_patches write "$TARGET"
printf "\n---------------------------------------------------------------"
printf "\nSummary: %d patched, %d skipped, %d failed." "$COUNT" "$SKIPPED" "$FAIL"
if [ "$FAIL" -gt 0 ]; then
	log_exit "Error: some patches failed. Aborting."
fi

# Write the patched file back to the factory partition
printf "\n\nWriting to $MTD_LABEL ($MTD_DEV)\n\n"
mtd write "$TARGET" "$MTD_LABEL" && printf "\nWrote patched file to $MTD_LABEL ($MTD_DEV)." || {
	log_exit "Error: failed to write patched file back to $MTD_LABEL."
}

printf "\n\nVerifying $MTD_LABEL ($MTD_DEV):"
printf "\n---------------------------------------------------------------"
# Verify the patches by reading the factory partition again and comparing the values
loop_patches verify "${MTD_DEV}ro"
if [ "$FAIL" -gt 0 ]; then
	printf "\n\nError: some patches failed verification.\n\nTrying to restore from backup..."
	# Restore the backup if verification fails
	mtd write "${TARGET}.backup" "$MTD_LABEL" && printf "\nBackup restored." || {
		printf "\n\nCritical Error: failed to restore backup. Please check the device."
	}
	exit 1
fi

printf "\n\n================================================================"
printf "\nBackup file is located at ${TARGET}.backup."
printf "\n\nPlease reboot the device to apply the changes."
printf "\n================================================================\n"

# Exit with zero status
exit 0
