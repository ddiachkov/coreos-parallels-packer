COREOS_RELEASE ?= stable
COREOS_IMAGE_DIGEST_URL ?= http://$(COREOS_RELEASE).release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso.DIGESTS
COREOS_CLOUD_CONFIG ?= cloud-config.yml

coreos: output/coreos/coreos-$(COREOS_RELEASE).pvm/
coreos-prlt: output/coreos-prlt/coreos-$(COREOS_RELEASE)-prlt.pvm/

vagrant: output/vagrant/parallels-coreos-$(COREOS_RELEASE).box
vagrant-prlt: output/vagrant/parallels-coreos-$(COREOS_RELEASE)-prlt.box

output/coreos/coreos-$(COREOS_RELEASE).pvm/:
	$(eval COREOS_IMAGE_ISO_CHECKSUM := $(shell curl -s "$(COREOS_IMAGE_DIGEST_URL)" | grep "coreos_production_iso_image.iso" | awk '{ print length, $$1 | "sort -rg"}' | awk 'NR == 1 { print $$2 }'))

	packer build -force \
		-var 'coreos-release=$(COREOS_RELEASE)' \
		-var 'cloud-config=$(COREOS_CLOUD_CONFIG)' \
		-var 'iso-checksum-type=sha512' \
		-var 'iso-checksum=$(COREOS_IMAGE_ISO_CHECKSUM)' \
		coreos.json

output/coreos-prlt/coreos-$(COREOS_RELEASE)-prlt.pvm/: output/coreos/coreos-$(COREOS_RELEASE).pvm/
	packer build -force -var 'coreos-release=$(COREOS_RELEASE)' coreos-prlt.json

output/vagrant/parallels-coreos-$(COREOS_RELEASE).box: output/coreos/coreos-$(COREOS_RELEASE).pvm/
	rm -rf $@
	packer build -force -var "vm=$<" -var "output=$@" vagrant.json

output/vagrant/parallels-coreos-$(COREOS_RELEASE)-prlt.box: output/coreos-prlt/coreos-$(COREOS_RELEASE)-prlt.pvm/
	rm -rf $@
	packer build -force -var "vm=$<" -var "output=$@" vagrant.json

clean:
	rm -rf output

.PHONY: clean