# docker-alpine-init

[![](https://badge.imagelayers.io/robwdux/docker-alpine-init:latest.svg)](https://imagelayers.io/?images=robwdux/docker-alpine-init:latest 'Get your own badge on imagelayers.io')

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
                   robwdux/docker-alpine-init \
                   bash
```
### shell into a daemonized running container
```shell
sudo docker run -d \
                --name init \
                robwdux/docker-alpine-init \
                ping 8.8.8.8 && \
sudo docker exec -it init bash

# in container
bash-4.3# ps
PID   USER     TIME   COMMAND
    1 root       0:00 s6-svscan -t0 /var/run/s6/services
   21 root       0:00 foreground  if   /etc/s6/init/init-stage2-redirfd   foreground    if     if      s6-echo      -n      --      [s6-init] making
   22 root       0:00 s6-supervise s6-fdholderd
   26 root       0:00 foreground  s6-setsid  -gq  --  with-contenv  ping  8.8.8.8  import -u ? if  s6-echo  --  ping exited ${?}  foreground  redirfd
   99 root       0:00 /bin/busybox ping 8.8.8.8
  100 root       0:00 bash
  106 root       0:00 ps

bash-4.3# ps -o user,group,comm,pid,ppid
USER     GROUP    COMMAND          PID   PPID
root     root     s6-svscan            1     0
root     root     foreground          21     1
root     root     s6-supervise        22     1
root     root     foreground          26    21
root     root     busybox             99    26
root     root     bash               100     0
root     root     ps                 105   100

```
## Customization

### [Working with Alpine Linux](https://github.com/robwdux/docker-alpine-base#working-with-alpine-linux) overview

### Working with s6 init system

+ [Getting Started](http://blog.tutum.co/2015/05/20/s6-made-easy-with-the-s6-overlay/)

+ [Project source repo and doc used for this container](https://github.com/just-containers/s6-overlay)

+ [s6 Official Information](http://skarnet.org/software/s6/)

+ [Docker and s6](http://blog.tutum.co/2014/12/02/docker-and-s6-my-new-favorite-process-supervisor/)
