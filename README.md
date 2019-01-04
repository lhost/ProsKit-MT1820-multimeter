# Pro'sKit MT1820 Multimeter Probe

Connect your multimeter [Pro'sKit MT-1820](https://www.prokits.com.tw/Product/MT-1820/) to your linux computer and read data over USB cable.

![Pro'sKit MT1820](https://ref.prokits.com.tw/ProductPic/MT-1820/1/20180531174031219179.jpg)

## Features

`multimeter-read.pl` script is tested with following multimeter(s):

- Models MT-1820 - MT-1860 have the same Windows drivers and documentation. They should work with this software, but they are not tested yet.

| Specification	| Range	| [MT-1820](https://www.prokits.com.tw/Product/MT-1820/)	|
|---			|---:	|:---:		|
| DCV			| 600mV	| Y			|
| DCV			| 6V	| Y			|
| DCV			| 60V	| 			|
| DCV			| 600V	| 			|
| DCV			| 1000V	| 			|
| ACV			| 600mV	| Y			|
| ACV			| 6V	| Y			|
| ACV			| 60V	| 			|
| ACV			| 600V	| Y			|
| ACV			| 750V	| 			|
| DCA			| 600μA	| Y			|
| DCA			| 6mA	| Y			|
| DCA			| 60mA	| Y			|
| DCA			| 600mA	| Y			|
| DCA			| 6A	| Y			|
| DCA			| 10A	|  			|
| ACA			| 600μA	|  			|
| ACA			| 6mA	| Y			|
| ACA			| 60mA	| Y			|
| ACA			| 600mA	| Y			|
| ACA			| 6A	| Y			|
| ACA			| 10A	|  			|
| Resistance	| 6Ω	| Y			|
| Resistance	| 60Ω	| Y			|
| Resistance	| 600Ω	| Y			|
| Resistance	| 6kΩ	| Y			|
| Resistance	| 60kΩ	| Y			|
| Resistance	| 600kΩ	| Y			|
| Resistance	| 6MΩ	| Y			|
| Resistance	| 60MΩ	| Y			|
| Frequency		| 100Hz	| 			|
| Frequency		| 1kHz	| 			|
| Frequency		| 10kHz	| 			|
| Frequency		| 100kHz	| 			|
| Frequency		| 1MHz		| 			|
| Frequency		| 30MHz		| 			|
| Capacitance	| 40nF		| 			|
| Capacitance	| 400nF		| 			|
| Capacitance	| 4μF		| 			|
| Capacitance	| 40μF		| 			|
| Capacitance	| 200μF		| 			|
| Temperature	| -20˚C		| 			|
| Temperature	| 0˚C		| 			|
| Temperature	| 20˚C		| Y			|
| Temperature	| 100˚C		| 			|
| Temperature	| 400˚C		| 			|
| Temperature	| 1000˚C	| 			|
| Temperature	| 0˚F		| 			|
| Temperature	| 100˚F		| Y			|
| Temperature	| 750˚F		| 			|
| Continuity with buzzer		| Y		| 			|
| Diode test		| 		| Y			|
| Transistor test	| NPN	| 			|
| Transistor test	| PNP	| 			|


- **TBD** - To Be Done
- **Y** - Yes
- **N** - No

## Getting Started

### Prerequisites

- [Pro'sKit MT-1820](https://www.prokits.com.tw/Product/MT-1820/) multimeter or similiar
- Linux operating system
- Perl

## Installing

```bash
git clone https://github.com/lhost/ProsKit-MT1820-multimeter
cd ProsKit-MT1820-multimeter
perl Makefile.PL
sudo make install
```

## Running the tests

```bash
make unittest
```

## Usage

```bash
./bin/multimeter-read.pl /dev/ttyUSB0
```

For other options see help and/or manual page:

```bash
./bin/multimeter-read.pl --help
./bin/multimeter-read.pl --man
```


## Debugging

If your multimeter is recognised by linux kernel, the following message should appear in `dmesg` output:

     usb 1-11: new full-speed USB device number 6 using xhci_hcd
     usb 1-11: New USB device found, idVendor=10c4, idProduct=ea60
     usb 1-11: New USB device strings: Mfr=1, Product=2, SerialNumber=3
     usb 1-11: Product: CP2102 USB to UART Bridge Controller
     usb 1-11: Manufacturer: Silicon Labs
     usb 1-11: SerialNumber: 0001
     cp210x 1-11:1.0: cp210x converter detected
     usb 1-11: cp210x converter now attached to ttyUSB0

and you should see the following USB device:

```bash
# lsusb | grep -i cp210x
Bus 001 Device 006: ID 10c4:ea60 Cygnal Integrated Products, Inc. CP210x UART Bridge / myAVR mySmartUSB light

# ls -la /dev/ttyUSB0
crw-rw---- 1 root dialout 188, 0 Jan  3 23:14 /dev/ttyUSB0
```
You can use standard serial port terminal to see binary data from you serial device:

```bash
minicom --baudrate 2400 -D /dev/ttyUSB0
```
- use **CTRL-a x** keys to exit minicom

## Original Windows software

Windows binary `handcom1820_1860.exe` can be started with `wine`.

Windows installer `CP210xVCPInstaller_x64.exe` is not required.

## Contributing

Please create Pull Request on [GitHub](https://github.com/lhost/ProsKit-MT1820-multimeter).

## Credits

- https://github.com/drahoslavzan/ProsKit-MT1820-Probe/ - Reverse engineered multimeter protol

## Authors

* **Lubomir Host** - *Initial work* - [lhost](https://github.com/lhost)

## License

This project is licensed under the GNU GPLv2 License - see the [LICENSE.md](LICENSE.md) file for details.
