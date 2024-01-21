#!/bin/bash

# Function to display the menu
display_menu() {
    echo "Choose the boot device:"
    echo "    1. microSD"
    echo "    2. USB"
    echo "    3. Quit"
}

# Function to validate user choice
validate_choice() {
    local choice=$1
    if [ "$choice" -ge 1 ] && [ "$choice" -le 3 ]; then
        return 0
    else
        return 1
    fi
}

# Command to determine the boot device
boot_device=$(df -h | grep '/$' | sed 's/\(^\/dev\/\w*\).*/\1/')
name_device=""
next_boot=""

# Check if the boot device is mmcblk0, then it's microSD
if echo "$boot_device" | grep -q "mmcblk0"; then
    name_device="microSD"
else
    # Otherwise, it's USB
    name_device="USB"
fi

# Display the current boot device
echo "Current boot device: $name_device"

# If an argument is provided, use it to directly choose the option
if [ "$#" -eq 1 ]; then
    case "$1" in
        "microsd")
            user_choice=1
            ;;
        "usb")
            user_choice=2
            ;;
        *)
            echo "Invalid argument. Usage: $0 [microsd|usb]"
            exit 1
            ;;
    esac
else
    # Display a menu to allow the user to choose the boot device
    display_menu
    read -p "Your choice (1, 2, or 3): " user_choice

    # Validate user choice
    if ! validate_choice "$user_choice"; then
        echo "Invalid choice."
        exit 1
    fi
fi

case $user_choice in
    1)
        if [ "$name_device" = "microSD" ]; then
            if [ ! -e "/boot/firmware/bootcode.bak" ] && [ -e "/boot/firmware/bootcode.bin" ]; then
                echo "No change. Currently, the system boots from the microSD card."
            else
                if [ -e "/boot/firmware/bootcode.bak" ] && [ ! -e "/boot/firmware/bootcode.bin" ]; then
                    sudo mv "/boot/firmware/bootcode.bak" "/boot/firmware/bootcode.bin"
                    echo "You chose to boot from the microSD card."
                fi
            fi
        else
            # Check if the mount point exists, create it if not
            if [ ! -d "/mnt/sdcard" ]; then
                mkdir /mnt/sdcard
            fi
            # Check if the mount point is already mounted
            if mountpoint -q /mnt/sdcard; then
                echo "The mount point is already mounted."
            else
                # Mount the microSD volume
                sudo mount /dev/mmcblk0p1 /mnt/sdcard
                # Check if the mount was successful
                if [ $? -eq 0 ]; then
                    echo "The microSD volume was mounted successfully."
                else
                    echo "Error mounting the microSD volume."
                    exit 1
                fi
            fi
            # Check if the microSD boot support is already selected
            if [ ! -e "/mnt/sdcard/bootcode.bak" ] && [ -e "/mnt/sdcard/bootcode.bin" ]; then
                echo "The microSD boot support is already selected."
            else
                if [ -e "/mnt/sdcard/bootcode.bak" ] && [ ! -e "/mnt/sdcard/bootcode.bin" ]; then
                    # The current boot device is USB, rename bootcode.bin to boot from microSD
                    sudo mv "/mnt/sdcard/bootcode.bak" "/mnt/sdcard/bootcode.bin"
                    echo "You chose to boot from the microSD card."
                fi
            fi
        fi
        next_boot="microSD"
        ;;
    2)
        if [ "$name_device" = "USB" ]; then
            # Check if the mount point exists, create it if not
            if [ ! -d "/mnt/sdcard" ]; then
                mkdir /mnt/sdcard
            fi
            # Check if the mount point is already mounted
            if mountpoint -q /mnt/sdcard; then
                echo "The mount point is already mounted."
            else
                # Mount the microSD volume
                sudo mount /dev/mmcblk0p1 /mnt/sdcard
                # Check if the mount was successful
                if [ $? -eq 0 ]; then
                    echo "The microSD volume was mounted successfully."
                else
                    echo "Error mounting the microSD volume."
                    exit 1
                fi
            fi
            # Check if the USB boot support is already selected
            if [ -e "/mnt/sdcard/bootcode.bak" ] && [ ! -e "/mnt/sdcard/bootcode.bin" ]; then
                echo "No change. Currently, the system boots from a USB device."
            else
                if [ ! -e "/mnt/sdcard/bootcode.bak" ] && [ -e "/mnt/sdcard/bootcode.bin" ]; then
                    # The selected boot device is microSD, rename bootcode.bin to boot from USB
                    sudo mv "/mnt/sdcard/bootcode.bin" "/mnt/sdcard/bootcode.bak"
                    echo "You chose to boot from a USB device."
                fi
            fi
        else
            if [ -e "/boot/firmware/bootcode.bak" ] && [ ! -e "/boot/firmware/bootcode.bin" ]; then
                echo "The USB boot support is already selected."
            else
                # If the current boot device is the microSD card, restore to boot from a USB device
                if [ ! -e "/boot/firmware/bootcode.bak" ] && [ -e "/boot/firmware/bootcode.bin" ]; then
                    sudo mv "/boot/firmware/bootcode.bin" "/boot/firmware/bootcode.bak"
                    echo "You chose to boot from a USB device."
                fi
            fi
        fi
        next_boot="USB"
        ;;
    3)
        echo "Program terminated."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

# Unmount if already mounted
if mountpoint -q /mnt/sdcard; then
    sudo umount /mnt/sdcard
fi

# Display the selected boot device
echo "Boot device selected for the next restart: $next_boot"

# Propose a restart
read -p "Do you want to restart now? (Y/n): " restart_choice
if [ "$restart_choice" != "n" ]; then
    echo "Restarting..."
    sudo reboot
else
    echo "Restart not performed. Make sure to restart later."
fi
