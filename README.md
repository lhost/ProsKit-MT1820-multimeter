Pro'sKit MT1820 Multimeter Probe
================================

Connect your multimeter [Pro'sKit MT-1820](https://www.prokits.com.tw/Product/MT-1820/) to your linux computer and read data over USB cable.

![Pro'sKit MT1820](https://ref.prokits.com.tw/ProductPic/MT-1820/1/20180531174031219179.jpg)

## Linux installation

```bash
git clone https://github.com/lhost/ProsKit-MT1820-multimeter
cd ProsKit-MT1820-multimeter
perl Makefile.PL
sudo make install
```

## Usage

```bash
./bin/multimeter-read.pl /dev/ttyUSB0
```

## Original Windows software

Windows binary `handcom1820_1860.exe` can be started with `wine`.

Windows installer `CP210xVCPInstaller_x64.exe` is not required.

