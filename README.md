# Pro'sKit MT1820 Multimeter Probe

Connect your multimeter [Pro'sKit MT-1820](https://www.prokits.com.tw/Product/MT-1820/) to your linux computer and read data over USB cable.

![Pro'sKit MT1820](https://ref.prokits.com.tw/ProductPic/MT-1820/1/20180531174031219179.jpg)

## Features

`multimeter-read.pl` script is tested with following multimeter(s):

- Models MT-1820 - MT-1860 have the same Windows drivers and documentation. They should work with this software, but they are not tested yet.

| Specification	| Range	| [MT-1820](https://www.prokits.com.tw/Product/MT-1820/)	|
|---			|---:	|:---:		|
| DCV			| 600mV	| 			|
| DCV			| 6V	| 			|
| DCV			| 60V	| 			|
| DCV			| 600V	| 			|
| DCV			| 1000V	| TBD		|
| ACV			| 6V	| 			|
| ACV			| 60V	| 			|
| ACV			| 600V	| 			|
| ACV			| 750V	| TBD		|
| DCA			| 600μA	|  			|
| DCA			| 6mA	|  			|
| DCA			| 60mA	|  			|
| DCA			| 600mA	|  			|
| DCA			| 6A	|  			|
| DCA			| 10A	|  			|
| ACA			| 600μA	|  			|
| ACA			| 6mA	|  			|
| ACA			| 60mA	|  			|
| ACA			| 600mA	|  			|
| ACA			| 6A	|  			|
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
| Temperature	| 20˚C		| 			|
| Temperature	| 100˚C		| 			|
| Temperature	| 400˚C		| 			|
| Temperature	| 1000˚C	| 			|
| Temperature	| 0˚F		| 			|
| Temperature	| 750˚F		| 			|
| Continuity with buzzer		| 		| 			|
| Diode test		| 		| 			|
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
