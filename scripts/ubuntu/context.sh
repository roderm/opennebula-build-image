#!/bin/sh
apt update
apt remove -y cloud-init network-manager
apt install -y \
	qemu-guest-agent \
	haveged rng-tools \
	cloud-utils \
	util-linux \
	ruby
apt install -y /mnt/one-context.deb
apt install -f -y

systemctl enable haveged