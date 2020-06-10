FROM archlinux:latest

RUN pacman -Syu qemu --noconfirm;

WORKDIR /data

ENTRYPOINT ["qemu-img", "create", "-f", "qcow2", "mac_hdd_ng.img"]

CMD [ "32G" ]
