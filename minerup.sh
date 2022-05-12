#!/bin/bash

REGION=`uci get miner.general.region`
VERSION=`uci get miner.general.version`
MINER=`uci get miner.general.image`
SYNC_PEER=`uci get miner.general.syncpeer`
PORT=`uci get miner.general.port`

## Default Setting
[[ -z ${REGION} ]] && REGION="US915"
[[ -z ${VERSION} ]] && VERSION="2022.05.11.0"
[[ -z ${MINER} ]] && VERSION="miner-arm64_2022.05.11.0"
[[ -z ${SYNC_PEER} ]] && SYNC_PEER="/ip4/47.89.8.92/tcp/44158"
[[ -z ${PORT} ]] && PORT="44158"


MINER_HOME="/home/miner"
MINER_DATA="$MINER_HOME/miner_data"
LOGFILE="$MINER_HOME/miner-manager.log"

## NO Login ?
PWD=`pwd`
cd $MINER_HOME

# delete miner form docker if miner runing

delete_update() {
    local RUNID=`docker ps -aqf "name=miner"`
    [[ -n ${RUNID} ]] &&
        docker stop miner &&
    docker container rm -f miner

#    imageID=`docker images -q --filter reference=quay.io/team-helium/miner`
#    [[ -n ${imageID} ]] && docker image rm ${imageID}

    ## remove all volume which dangling status equal to true
#    docker system prune --force

    # update new version of miner

    docker run -d --init \
               --ulimit nofile=64000:64000 \
               --env REGION_OVERRIDE=${REGION} \
               --publish 1680:1680/udp \
               --publish $PORT:44158/tcp \
               --restart always \
               --name miner \
               --device /dev/i2c-1 \
               --network bridge \
               --privileged \
               -v /var/run/dbus:/var/run/dbus \
               --mount type=bind,source=$MINER_DATA/config/docker.config,target=/opt/miner/releases/${VERSION}/sys.config \
               --mount type=bind,source=$MINER_DATA,target=/var/data \
               quay.io/team-helium/miner:${MINER}
}

new_container() {
    local RUNID=`docker ps -aqf "name=miner"`
    [[ -n ${RUNID} ]] &&
        docker stop miner &&
            docker container rm -f miner

    docker run -d --init \
               --ulimit nofile=64000:64000 \
               --env REGION_OVERRIDE=${REGION} \
               --publish 1680:1680/udp \
               --publish $PORT:44158/tcp \
               --restart always \
               --name miner \
               --device /dev/i2c-1 \
               --network bridge \
               --privileged \
               -v /var/run/dbus:/var/run/dbus \
               --mount type=bind,source=$MINER_DATA/config/docker.config,target=/opt/miner/releases/${VERSION}/sys.config \
               --mount type=bind,source=$MINER_DATA,target=/var/data \
               quay.io/team-helium/miner:${MINER}
}

do_flush_sync() {
    docker stop miner

    ## bakup config
    [[ -f $MINER_DATA/miner/swarm_key ]]  &&  cp -f $MINER_DATA/miner/swarm_key $MINER_HOME
    [[ -f $MINER_DATA/config/docker.config ]]  &&  cp -f $MINER_DATA/config/docker.config $MINER_HOME

    ## delete all files
    rm -rf $MINER_DATA/??*

    ## get the newest configure
    [[ -f $MINER_HOME/docker_lastest.config ]] && rm -rf $MINER_HOME/docker_lastest.config
    wget http://repo.dragino.com/miner/docker_lastest.config

    [[ -f $MINER_HOME/swarm_key ]] && mkdir -p  $MINER_DATA/miner && mv $MINER_HOME/swarm_key $MINER_DATA/miner

    mkdir -p  $MINER_DATA/config

    if [ -f $MINER_HOME/docker_lastest.config ]; then
        mv $MINER_HOME/docker_lastest.config $MINER_DATA/config/docker.config
    else
        mv $MINER_HOME/docker.config $MINER_DATA/config/docker.config
    fi

    docker start miner

    ## connect the sysnc server for fast sync
    sleep 5
    docker exec miner miner peer connect $SYNC_PEER
}

do_fast_sync() {
    docker exec miner miner peer connect $SYNC_PEER
}

update() {
    delete_update

    sleep 2

    RUNID=`docker ps -aqf "name=miner"`

    while [[ -z ${RUNID} ]]; do
        logger -t minerup "Failed to update miner image: version=${VERSION}"
        sleep 5
        delete_update
        sleep 2
        RUNID=`docker ps -aqf "name=miner"`
    done
    logger -t minerup "successed for update miner image, version=${VERSION}"
}

case "$1" in
    update)
        update
        ;;
    flush)
        do_flush_sync
        ;;
    sync)
    do_fast_sync
        ;;
    new)
        new_container
        ;;
    *)
        update
        ;;
esac

cd $PWD

exit

