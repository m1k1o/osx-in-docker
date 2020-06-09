# osx in docker

```
docker build -t osx .
docker run -p 5901:5901 -d --privileged --cap-add=ALL -v /lib/modules:/lib/modules -v /dev:/dev osx
```

Inspired by:
* https://github.com/sickcodes/Docker-OSX
* https://github.com/kholia/OSX-KVM
* https://artem.services/?p=752&lang=en

### Is This Legal?

The "secret" Apple OSK string is widely available on the Internet. It is also included in a public court document [available here](http://www.rcfp.org/sites/default/files/docs/20120105_202426_apple_sealing.pdf). I am not a lawyer but it seems that Apple's attempt(s) to get the OSK string treated as a trade secret did not work out. Due to these reasons, the OSK string is freely included in this repository.

Gabriel Somlo also has [some thoughts](http://www.contrib.andrew.cmu.edu/~somlo/OSXKVM/) on the legal aspects involved in running macOS under QEMU/KVM.
