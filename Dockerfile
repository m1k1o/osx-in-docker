FROM archlinux:latest

# change disk size here or add during build, e.g. --build-arg VERSION=10.14.6 --build-arg SIZE=50G
ARG SIZE=32G
ARG VERSION=10.14.6

RUN tee -a /etc/pacman.conf <<< '[community-testing]'; \
    tee -a /etc/pacman.conf <<< 'Include = /etc/pacman.d/mirrorlist'; \
    #
    # install packages
    pacman -Syu sudo git make automake gcc python go autoconf cmake pkgconf alsa-utils fakeroot \
    tigervnc xterm xorg-xhost xdotool ufw --noconfirm; \
    #
    # add user
    useradd arch; \
    echo 'arch ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers; \
    mkdir /home/arch; \
    chown arch:arch /home/arch;

USER arch

WORKDIR /home/arch/yay
RUN git clone https://aur.archlinux.org/yay.git .; \
    makepkg -si --noconfirm; \
    #
    # install packages
    sudo pacman -Syu qemu libvirt dnsmasq virt-manager bridge-utils flex bison ebtables edk2-ovmf \
    netctl libvirt-dbus libguestfs --noconfirm;

WORKDIR /home/arch/gibMacOS
RUN git clone https://github.com/corpnewt/gibMacOS.git .; \
    sed -i -e 's/print("Succeeded:")/exit()/g' gibMacOS.command; \
    #
    # download os
    python gibMacOS.command -v "${VERSION}" -d;

WORKDIR /home/arch/OSX-KVM
RUN git clone https://github.com/kholia/OSX-KVM.git .; \
    #
    # create images
    qemu-img convert /home/arch/gibMacOS/macOS\ Downloads/publicrelease/*/BaseSystem.dmg -O raw /home/arch/OSX-KVM/BaseSystem.img; \
    qemu-img create -f qcow2 mac_hdd_ng.img "${SIZE}";

ENV DISPLAY :0.0
ENV USER arch

COPY boot.sh boot.sh
ENTRYPOINT ./boot.sh
