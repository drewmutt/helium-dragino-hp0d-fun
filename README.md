# helium-dragino-hp0d-fun

### Update to newest miner..
docker stop miner && docker rm miner
docker run -d --init \
--ulimit nofile=64000:64000 \
--env REGION_OVERRIDE=US915 \
--restart always \
--publish 1680:1680/udp \
--publish 44158:44158/tcp \
--name miner \
--mount type=bind,source=/home/miner/miner_data,target=/var/data \
quay.io/team-helium/miner:miner-arm64_2022.05.10.0_GA


### Helpful-ish links
https://docs.helium.com/mine-hnt/full-hotspots/become-a-maker/basic-miner-operation/
