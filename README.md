# coreos-parallels-packer
This repository contains [Packer](http://www.packer.io) templates to generate CoreOS Parallels VM with __parallels tools installed__.

## Prerequisites
* [Packer](https://packer.io/intro/getting-started/setup.html)
* [Parallels Desktop 10](http://www.parallels.com/products/desktop)
* [Parallels Virtualization SDK 10](http://www.parallels.com/download/pvsdk)

## Usage
To build base image:
```shell
make coreos COREOS_VERSION="..."
```
Where COREOS_VERSION is "stable" (default), "beta" or "alpha"
Result VM will be generated in directory `output/coreos`.

To build base image AND install Parallels tools to it:
```shell
make coreos-prlt COREOS_VERSION="..."
```
Result VM will be generated in directory `output/coreos-prlt`.

By default you can logon to generated machine with vagrant insecure key:
```shell
ssh -i keys/vagrant core@<ip-address>
```

You can also pass custom cloud-config:
```shell
make coreos COREOS_CLOUD_CONFIG="custom-cloud-config.yml"
```

### Vagrant
To generate Vagrant box without parallels tools:
```shell
make vagrant COREOS_VERSION="..."
```

To generate Vagrant box with parallels tools:
```shell
make vagrant-prlt COREOS_VERSION="..."
```
Box will be generated in `output/vagrant`.
