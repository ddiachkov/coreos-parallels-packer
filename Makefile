coreos-prlt: coreos
	packer build -force coreos-prlt.json

coreos:
	packer build -force coreos.json

clean:
	rm -rf output-parallels-iso
	rm -rf output-parallels-pvm

.PHONY: clean