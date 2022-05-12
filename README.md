# helium-dragino-hp0d-fun

### Update to newest miner..
```docker stop miner && docker rm miner
docker run -d --init \
--ulimit nofile=64000:64000 \
--env REGION_OVERRIDE=US915 \
--restart always \
--publish 1680:1680/udp \
--publish 44158:44158/tcp \
--name miner \
--mount type=bind,source=/home/miner/miner_data,target=/var/data \
quay.io/team-helium/miner:miner-arm64_2022.05.10.0_GA
```

### Helpful-ish links
https://docs.helium.com/mine-hnt/full-hotspots/become-a-maker/basic-miner-operation/
Hidden HP0D manual: https://manuals.plus/dragino/atecc608-hp0d-outdoor-helium-hotspot-manual
Dragino update script: `/usr/local/bin`

### Dragino first run scripts
`/usr/lib/dragino`

`/usr/local/dragino`

### Dragino config
`/etc/config`

Scared to do it, but here it is..
https://wiki.dragino.com/index.php?title=Reset_Factory_Default


. /etc/dragino-release
. /etc/os-release
. /lib/init/vars.sh
. /lib/lsb/init-functions
. /usr/lib/dragino/dragino-common
