# osx in docker

```
docker build -t osx .
docker run -p 5901:5901 -d --privileged --cap-add=ALL -v /lib/modules:/lib/modules -v /dev:/dev osx
```

inspired by:
https://github.com/sickcodes/Docker-OSX
