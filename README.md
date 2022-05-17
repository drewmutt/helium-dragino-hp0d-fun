# helium-dragino-hp0d-fun

### Update to newest miner..
```
docker stop miner && docker rm miner
docker run -d --init \
--ulimit nofile=64000:64000 \
--env REGION_OVERRIDE=US915 \
--restart always \
--publish 1680:1680/udp \
--publish 44158:44158/tcp \
--name miner \
--mount type=bind,source=/home/miner/miner_data,target=/var/data \
quay.io/team-helium/miner:miner-arm64_2022.05.13.0_GA
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

```
. /etc/dragino-release
. /etc/os-release
. /lib/init/vars.sh
. /lib/lsb/init-functions
. /usr/lib/dragino/dragino-common
```
### Wifi
After messing for days, asked Dragino, they replied promptly, but with a rando IP address wiki..
`http://8.211.40.43:8080/xwiki/bin/view/Main/User%20Manual%20for%20All%20Gateway%20models/HP0D/`
uploaded PDF here


trying to get it to connect to wifi.. woof..

https://forum.openwrt.org/t/static-wifi-configuration-with-wrong-password-is-still-detected-as-active/112966
Something is repeatedly overwriting config at:
`/etc/config/wireless`

`/etc/hostapd/hostapd.conf`
`nmcli con add con-name`?
`iw reg set "$FR_net_wifi_countrycode"`?
`/boot/dragino_first_run.txt`

I think the doing is here.. 
`/etc/init.d/iot`
```
 if [[ "$mode" = "lorawan" ]]; then
                systemctl start draginofwd
        elif [[ "$mode" = "station" ]]; then
                systemctl start draginostation
        elif [[ "$mode" = "lorawan" ]] && [[ "$provide" = "helium" ]]; then
                systemctl start draginofwd
                systemctl srart helium_gateway
```
so...
`uci set gateway.general.server_type=station`?

Host apd getting in the way.. dumped it.. 
`apt-get remove hostadp`?

I'll do it the hard way.. script..
```
cp /home/miner/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf #contains ssid
cp /home/dhcpcd.conf.bak /etc/dhcpcd.conf #strips static ip
iwconfig wlan0 mode managed
sudo wpa_supplicant -B -D wext -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
iw wlan0 connect MunchausenByProxy
ip link set wlan0 down
ip link set wlan0 up
iw wlan0 link
```


`nano /etc/systemd/system/multi-user.target.wants/dragino-firstrun-config.service`
`grep -Ril "HotsPot" /usr/lib/systemd`


