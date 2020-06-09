FROM archlinux:latest

# change disk size here or add during build, e.g. --build-arg VERSION=10.14.6 --build-arg SIZE=50G
ARG SIZE=32G
ARG VERSION=10.14.6

RUN tee -a /etc/pacman.conf <<< '[community-testing]'; \
	tee -a /etc/pacman.conf <<< 'Include = /etc/pacman.d/mirrorlist'; \
	#
	# install packages
	pacman -Syu git make automake gcc python go autoconf cmake pkgconf alsa-utils fakeroot \
	tigervnc xterm xorg-xhost xdotool ufw --noconfirm; \
	#
	# add user
	useradd arch; \
	mkdir /home/arch; \
	chown arch:arch /home/arch;

WORKDIR /home/arch/yay
RUN git clone https://aur.archlinux.org/yay.git .; \
	makepkg -si --noconfirm; \
	#
	# install packages
	pacman -Syu qemu libvirt dnsmasq virt-manager bridge-utils flex bison ebtables edk2-ovmf \
	netctl libvirt-dbus libguestfs --noconfirm;

WORKDIR /home/arch/gibMacOS
RUN git clone https://github.com/corpnewt/gibMacOS.git .; \
    sed -i -e 's/print("Succeeded:")/exit()/g' gibMacOS.command; \
	#
	# download os
    python gibMacOS.command -v "${VERSION}" -d;

WORKDIR /home/arch/OSX-KVM
RUN git clone https://github.com/kholia/OSX-KVM.git .; \
	qemu-img convert /home/arch/gibMacOS/macOS\ Downloads/publicrelease/*/BaseSystem.dmg -O raw /home/arch/OSX-KVM/BaseSystem.img; \
	qemu-img create -f qcow2 mac_hdd_ng.img "${SIZE}"; \
	sed -i -e 's/usb-mouse/usb-tablet/g' OpenCore-Boot.sh; \
	perl -p -i -e \
		's/-netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27/-netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:09:49:17/' \
		./OpenCore-Boot.sh; \
	chmod +x OpenCore-Boot.sh;

ENV DISPLAY :0.0
ENV USER arch

RUN chown -R arch:arch /home/arch/; \
	mknod /dev/kvm c 10 232; \
    chown 777 /dev/kvm

#USER arch
#VOLUME ["/tmp/.X11-unix"]
#CMD ./OpenCore-Boot.sh

#
# VNC
#RUN mkdir /home/arch/.vnc; \
#	printf '%s\n' \
#		'xinit &' \
#		'xterm &' > /home/arch/.vnc/xstartup; \
#	#
#	# modify boot file
#	printf '%s\n%s\n%s\n\n' \
#		'#!/usr/bin/env bash' \
#		'export DISPLAY=:99' \
#		'vncserver -geometry 1920x1080 -depth ${DEPTH:=24} -xstartup /home/arch/.vnc/xstartup :99' > OpenCore-Boot_vnc.sh; \
#	cat OpenCore-Boot.sh >> OpenCore-Boot_vnc.sh; \
#	chmod +x OpenCore-Boot_vnc.sh; \
#	#
#	# set up password
#	tee vncpasswd_file <<< "${VNC_PASSWORD:=$(openssl rand -hex 4)}"; \
#	vncpasswd -f < vncpasswd_file > /home/arch/.vnc/passwd; \
#	chmod 600 /home/arch/.vnc/passwd; \
#	printf '\n\n\n\n%s\n%s\n\n\n\n' '===========VNC_PASSWORD========== ' "$(<vncpasswd_file)"; \
#	cat ./OpenCore-Boot_vnc.sh;

COPY script.sh script.sh
CMD ./script.sh