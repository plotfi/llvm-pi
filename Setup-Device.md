## Setup Raspberry Pi with Ubuntu 20.04

You will need a Raspberry Pi arm64 device (preferably a Raspberry Pi 4), and a Micro SD Card.

Go to https://ubuntu.com/download/raspberry-pi and download the Ubuntu 20.04 image.

Next install the image to the Micro SD Card. To do follow the following steps for corresponding platform:

* Linux: https://ubuntu.com/tutorials/create-an-ubuntu-image-for-a-raspberry-pi-on-ubuntu#1-overview
* Windows: https://ubuntu.com/tutorials/create-an-ubuntu-image-for-a-raspberry-pi-on-windows#1-overview
* Mac: https://ubuntu.com/tutorials/create-an-ubuntu-image-for-a-raspberry-pi-on-macos#1-overview

Now in your system-boot volume on the SD Card (just written from the prior step),
edit the `network-config` before booting for the first time. Follow the step at
https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#3-wifi-or-ethernet to do this.

Now safely eject your sd card, put it in the Raspberry Pi 4, and plug it in. Your pi should join your wireless network. 
