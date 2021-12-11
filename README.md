[hub]: https://hub.docker.com/r/spritsail/bungeecord
[drone]: https://drone.spritsail.io/spritsail/bungeecord

# [Spritsail/Bungeecord][hub]

[![Docker Pulls](https://img.shields.io/docker/pulls/spritsail/bungeecord.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/spritsail/bungeecord.svg)][hub]
[![Build Status](https://drone.spritsail.io/api/badges/spritsail/bungeecord/status.svg)][drone]

An Alpine Linux based Dockerfile to run the Minecraft server proxy Bungeecord
It expects a volume to store data mapped to `/config` in the container. Enjoy!


## Example run command
```
docker run -d --restart=on-failure:10 --name bungeecord -v /volumes/bungeecord:/config -p 25577:25577 spritsail/bungeecord:latest
```
