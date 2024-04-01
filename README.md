# Raspberry boot switch

## Overview
This program alloww switching between microSD and USB boot on Raspberry Pi 1-2-3 using only ssh (no need to physically insert/remove SD card).

## Prerequisites
Ensure that USB boot is enabled on your Raspberry Pi. You can check the OTP status with the following command:

```bash
vcgencmd otp_dump | grep 17:
```

If `17:3020000a` is returned, USB boot is enabled. If `17:1020000a` is returned, USB boot is not enabled.

To enable USB boot, follow these instructions:

1. Update the system:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   sudo reboot
   ```

2. Update OTP:
   ```bash
   echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
   sudo reboot
   ```

3. Check OTP status again:
   ```bash
   vcgencmd otp_dump | grep 17:
   ```

   It should now show `17:3020000a`, indicating that USB boot is enabled.

## Installation
1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/broogly/rpi-boot-switch/main/rpi-boot-switch.sh
   ```

2. Move the script to /usr/local/bin/ :
   ```bash
   sudo mv rpi-boot-switch.sh /usr/local/bin/
   ```

3. Set execute permissions and create a symbolic link:
   ```bash
   sudo chmod +x /usr/local/bin/rpi-boot-switch.sh && sudo ln -s /usr/local/bin/rpi-boot-switch.sh /usr/local/bin/rpi-boot-switch
   ```

## Usage
You can use the `rpi-boot-switch` command to display the menu. Additionally, you can use the following commands to switch boot options directly:

- To switch to USB boot:
  ```bash
  rpi-boot-switch usb
  ```

- To switch to microSD boot:
  ```bash
  rpi-boot-switch microsd
  ```

Feel free to use these commands according to your preferences.

# Licencing

### MIT License

Copyright (c) 2024 Broogly

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# Support the Developer

If you find this script helpful and it saves you time or effort, consider supporting the development by buying me a coffee. Your contribution helps in keeping this project active and improving.

[![Buy Me a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/broogly)

Scan the QR code to buy me a coffee:

<img src="https://github.com/broogly/rpi-boot-switch/raw/main/bmc_qr.png" alt="Buy Me a Coffee QR Code" width="260">

Your support is greatly appreciated! Thank you for helping to fuel more useful tools and projects.
