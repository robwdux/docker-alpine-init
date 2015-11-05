# docker-alpine-init

## [Alpine Linux](http://alpinelinux.org/) base image plus s6 init system

Built FROM [robwdux/alpine-base](https://github.com/robwdux/docker-alpine-base)

### ...start your Dockerfile

```shell
FROM robwdux/alpine-init
```

+ Provides s6 init system via [s6-overlay](https://github.com/just-containers/s6-overlay), cURL and Bash

+ [Leverages fast CDN backed package mirrors provided by fastly courtesy of Gliderlabs](http://gliderlabs.com/blog/2015/09/23/fastly-cdn-speeds-up-alpine-package-installs/)

## Test Drive

### shell in interactively
```shell
sudo docker run --rm -it \
                   --name init \
                   registry:5000/alpine/init \
                   bash
```
### shell into a daemonized running container
```shell
sudo docker run -d \
                --name init \
                registry:5000/alpine/init \
                ping 8.8.8.8 && \
sudo docker exec -it bash
```

## Working with Alpine Linux

+ [Alpine Linux Docker Image](http://gliderlabs.viewdocs.io/docker-alpine/)

+ [Caveats](http://gliderlabs.viewdocs.io/docker-alpine/caveats/)

+ [Packages](https://pkgs.alpinelinux.org/packages)

+ [Package Management](http://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management)

## Working with s6 init system

+ [Getting Started](http://blog.tutum.co/2015/05/20/s6-made-easy-with-the-s6-overlay/)

+ [Project source repo and doc used for this container](https://github.com/just-containers/s6-overlay)

+ [s6 Official Information](http://skarnet.org/software/s6/)

+ [Docker and s6](http://blog.tutum.co/2014/12/02/docker-and-s6-my-new-favorite-process-supervisor/)
