# docker-alpine-init
<!---
[![](https://badge.imagelayers.io/robwdux/docker-alpine-init:latest.svg)](https://imagelayers.io/?images=robwdux/docker-alpine-init:latest 'Get your own badge on imagelayers.io')
-->

_**Provides s6 init system via [s6-overlay](https://github.com/just-containers/s6-overlay) in addition to that provided by [robwdux/alpine-base](https://github.com/robwdux/docker-alpine-base)**_

See [below](#working-with-s6-init-system) for help with the s6 init system

Addons available selectively during build. Assisting applications include:
+ [telegraf](https://github.com/influxdata/telegraf/blob/master/README.md) for exporting metrics (e.g. read a stats endpoint and stream to [influxdb](https://github.com/influxdata/influxdb/blob/master/README.md) or another of the supported [outputs](https://github.com/influxdata/telegraf#supported-output-plugins))
+ [consul-template](https://github.com/hashicorp/consul-template/blob/master/README.md) for dynamic configuration (requires [consul](https://www.consul.io/intro/index.html))

## [Alpine Linux](http://alpinelinux.org/) base image plus s6 init system

**Control the initialization, runtime and shutdown of containers through multi stage init.**
+ process supervision, especially for *assisting* processes
+ reap defunct *"zombie"* processes (specifically for applications that spawn additional processes), mitigating a full process table

**3 Stage Init system**

Stage 1:
+ s6-init setup

Stage 2:
+ container initialization - execute code prior to starting services, e.g. apply runtime configuration
+ process supervision - start and supervise defined services under the service directory

Stage 3:
+ container shutdown - execute code prior to service(s) being stopped

### ...start your Dockerfile

```shell
FROM robwdux/alpine-init
```

**_Processes should not daemonize, but run in foreground under supervision of the init system_**

**_Processes should log to standard error and standard out_**

Leverage the docker log driver to stream logs off the host without incurring the i/o hit on disk.

## Test Drive, Iterate for a new image

*Interactively test commands and such then record in a Dockerfile for a new project*

### Build or run with docker-compose
```shell
# add short alias for docker-compose
echo "alias dc='docker-compose '" >> ~/.bashrc && source ~/.bashrc

# the repo
git clone https://github.com/robwdux/docker-alpine-init.git

cd docker-alpine-init/

# build and run (image doesn't exist locally)
dc run --rm -ti init bash

# build explicitly
dc build

# build with meta data via build args for git info
sudo ./build.sh

# view meta data
$ docker inspect --format '{{ json .Config.Labels }}' robwdux/alpine-init:1.18.3.1 | jq
```

### shell in interactively
```shell
sudo docker run --rm -it \
                   --name init \
                   robwdux/docker-alpine-init \
                   sh
```
### shell into a daemonized running container
```shell
sudo docker run -d \
                --name init \
                robwdux/docker-alpine-init \
                ping 8.8.8.8 && \
sudo docker exec -it init sh

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
