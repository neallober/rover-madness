# Rover Madness
Monitor the progress of Lego MindStorm robots reaching their goals with NFC sensors and a realtime leaderboard.

### Program Components
There are three main components to this system:
  - nfc-pulse: This is a command-line program that talks to an attached PN532 NFC card and polls for nearby NFC cards
  - monitoring-station.rb: A ruby script that runs a socket server, listens for incoming connections, and re-generates an HTML file that displays progress.  This program should be run on the computer with the progress display attached.
  - pulse.rb: A ruby script that runs at each station and continuously runs nfc-pulse looking for nearby NFC chips.  When a chip is found, it will open a socket connectino to the monitoring station and pass an update.

### Files
| File name | Purpose |
|---|---|
| monitoring-station.rb | Ruby script that listens for socket connections and re-generates the status html page when progress updates are received. |
| nfc-pulse  | Command-line executable that finds an attached NFC reader and polls for nearby NFC tags |
| nfc-pulse.c  | Source code for the nfc-pulse program |
| pulse.rb | Ruby script to run nfc-pulse continuously. When NFC tags are found, open a socket connection to the specified monitoring server and send rover progress updates. |
| statuspage-template.html | Template used by the monitoring station to generate the HTML that displays rover progress. |
| statuspage-fragment-failure.html | Template for the HTML that is shown when rovers have not reached a station |
| statuspage-fragment-success.html | Template for the HTML that is shown when rovers succesfully reach a station |
| statuspage.css | CSS used to style the progress monitor HTML file |


### Rasberry Pi Setup Instructions

Start with a fresh installation of the raspbian OS.  Then perform the following:
```sh
sudo apt-get update
sudo apt-get upgrade
sudo raspi-config
```
From the configuration page, disable shell and kernel messages via UART.  Then open the following file:

```sh
sudo nano /boot/config.txt
```
and remove the line

```
enable_uart=0
```

if it exists. And add at the end of the file

```
enable_uart=1
sudo reboot
```
After the computer reboots, we need to install libnfc.  To do so, run the following commands:

```
$ cd /home/pi
$ mkdir libnfc
$ cd libnfc
$ wget https://github.com/nfc-tools/libnfc/releases/download/libnfc-1.7.1/libnfc-1.7.1.tar.bz2
$ tar -xvjf libnfc-1.7.0.tar.bz2
$ cd libnfc-1.7.1
$ sudo mkdir /etc/nfc
$ sudo mkdir /etc/nfc/devices.d
$ sudo cp contrib/libnfc/pn532_uart_on_rpi.conf.sample /etc/nfc/devices.d/pn532_uart_on_rpi.conf
```

Next we need to allow intrusive scanning on the NFC board, so we will need to make the following small change to a file:

```sh
sudo nano /etc/nfc/devices.d/pn532_uart_on_rpi.conf
```

Update the file to include the following line at the bottom:

```
allow_intrusive_scan = true
```

Now we're ready to build libnfc. Run the following commands:

```sh
$ sudo apt-get install autoconf
$ sudo apt-get install libtool
$ sudo apt-get install libpcsclite-dev libusb-dev
$ autoreconf -vis
$ ./configure --with-drivers=pn532_uart --sysconfdir=/etc --prefix=/usr
$ sudo make clean
$ sudo make install all
```



#### Credits:
Credit to https://learn.adafruit.com/adafruit-nfc-rfid-on-raspberry-pi/freeing-uart-on-the-pi and https://github.com/nfc-tools/libnfc
