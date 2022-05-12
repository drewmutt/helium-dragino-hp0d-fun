LASTUPTIME=$(cat ./_temp-uptime)
LASTBLOCKS=$(cat ./_temp-lastblock)
UPTIME=$(awk '{print int($1)}' /proc/uptime)
MINEH=$(docker exec miner miner info height | awk '{print $2}')
H=$(curl -s https://api.helium.io/v1/blocks/height | awk '{print substr($1, 19, 7)}')
let blocksLeft=$H-$MINEH
let elapsedTime=$UPTIME-$LASTUPTIME
let elapsedBlocks=$MINEH-$LASTBLOCKS
TIMEPERBLOCK=$(perl -E "say $elapsedTime/$elapsedBlocks")
TIMETOCOMPLETE=$(perl -E "say $TIMEPERBLOCK*$blocksLeft")
echo "Uptime............. $UPTIME"
echo "Miner Height....... $MINEH"
echo "Block Height....... $H"
echo "---"
echo "Blocks remaining... $blocksLeft"
echo "Time elapsed....... $elapsedTime s"
echo "Blocks elapsed..... $elapsedBlocks"
echo "---"
echo "Time per block..... $TIMEPERBLOCK s"
echo "Time to complete... $TIMETOCOMPLETE s"
echo $UPTIME > ./_temp-uptime
echo $MINEH > ./_temp-lastblock
