BUILDER=quay.io/rebeccajae/guestbuilder

UBUNTU_VERSION=20.04
UBUNTU_IMG=ubuntu-${UBUNTU_VERSION}-server-cloudimg-amd64.img
UBUNTU_URI=https://cloud-images.ubuntu.com/releases/${UBUNTU_VERSION}/release/${UBUNTU_IMG}

CONTEXT_VERSION=5.12.0.2
DEB_CONTEXT=https://github.com/OpenNebula/addon-context-linux/releases/download/v${CONTEXT_VERSION}/one-context_${CONTEXT_VERSION}-1.deb

kill:
	docker kill $(shell docker ps -q -f ancestor=quay.io/rebeccajae/guestbuilder)
	rm -rf tmp/*

.PHONEY: ubuntu_pull
ubuntu_pull:
	curl -L ${UBUNTU_URI} -o ${UBUNTU_IMG}
	curl -L ${DEB_CONTEXT} -o one-context.deb

.PHONEY: ubuntu_build
ubuntu_build:
	# mkdir -p tmp/{packages,scripts}
	mkdir -p tmp/packages
	mkdir -p dist
	cp one-context.deb tmp/packages/one-context.deb
	cp -R scripts/ubuntu/* tmp/packages
	cp ${UBUNTU_IMG} tmp/base.img
	
	echo '#!/bin/sh' > tmp/entry.sh
	echo 'mount LABEL=PACKAGES /mnt' >> tmp/entry.sh
	echo '/bin/sh /mnt/entry.sh' >> tmp/entry.sh

	$(eval DOCKER_ID := $(shell docker run -d --rm --mount type=bind,source="${PWD}/tmp/",target=/build ${BUILDER} bash -c "while true; do sleep 30; done;"))
	docker exec -it ${DOCKER_ID} bash -c "cd /build/ && genisoimage -o packages.iso -R -J -V PACKAGES packages/"
	docker exec -it ${DOCKER_ID} bash -c "cd /build/ && qemu-img create -f qcow2 -b base.img image.qcow2"
	docker exec -it ${DOCKER_ID} bash -c "cd /build/ && virt-customize -v -x --network --format qcow2 -a image.qcow2 --attach packages.iso --run entry.sh -root-password disabled"
	docker exec -it ${DOCKER_ID} bash -c "cd /build/ && qemu-img convert -f qcow2 -O qcow2 -o compat=1.1 image.qcow2 ubuntu.qcow2"
	docker kill  $(DOCKER_ID)
	mv tmp/ubuntu.qcow2 dist/
	rm -rf tmp/*

.PHONEY: ubuntu
ubuntu: ubuntu_pull ubuntu_build