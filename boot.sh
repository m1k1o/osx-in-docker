#!/usr/bin/env bash

# All credits for OpenCore support go to https://github.com/Leoyzen/KVM-Opencore and
# https://github.com/thenickdude/KVM-Opencore/. Thanks!

MEM="8192"
SMP="8,cores=4"
OPT="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"
MAC="52:54:00:09:49:17"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--mem) MEM="$2"; shift ;;
        -s|--smp) SMP="$2"; shift ;;
        -o|--opt) OPT="$2"; shift ;;
        -a|--mac) MAC="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

qemu-system-x86_64 \
    -vga std -nographic -vnc :1 \
    -enable-kvm -m "$MEM" -cpu "Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$OPT" \
    -machine q35 \
    -smp "$SMP" \
    -usb -device usb-kbd -device usb-tablet \
    -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
    -drive if=pflash,format=raw,readonly,file="./OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="./OVMF_VARS-1024x768.fd" \
    -smbios type=2 \
    -device ich9-intel-hda -device hda-duplex \
    -device ich9-ahci,id=sata \
    -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="./OpenCore-Catalina/OpenCore.qcow2" \
    -device ide-hd,bus=sata.2,drive=OpenCoreBoot \
    -drive id=InstallMedia,if=none,file="./BaseSystem.img",format=raw \
    -device ide-hd,bus=sata.3,drive=InstallMedia \
    -drive id=MacHDD,if=none,file="./mac_hdd_ng.img",format=qcow2 \
    -device ide-hd,bus=sata.4,drive=MacHDD \
    -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0,mac="$MAC" \
    -vga vmware
