# coreos-parallels-packer
This repository contains [Packer](http://www.packer.io) template to generate Parallels VM with stable CoreOS and __parallels tools installed__.

## Usage
First of all you'll need to [install](https://packer.io/intro/getting-started/setup.html) packer and of course Parallels Desktop 10.

To build base image:
```shell
packer build -force coreos.json
```
Box will be generated in directory `output-parallels-iso`.

To install Parallels tools to base image:
```shell
packer build -force coreos.json && packer build -force coreos-prlt.json
```
Box will be generated in directory `output-parallels-pvm`.

By default you can logon to generated box with vagrant insecure key:
```shell
ssh -i keys/vagrant core@<ip-address>
```

You can also pass custom cloud-config (only base image):
```shell
packer build -force -var="cloud-config=custom-cloud-config.yml" coreos.json
```

## Vagrant
If you want Vagrant box then run:
```shell
packer build -force -var "box=output-parallels-iso/packer-parallels-iso.pvm" vagrant.json
```
Where `box` is path to generated VM. Vagrant box will be generated in current directory.
