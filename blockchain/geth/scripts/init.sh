#!/bin/sh
if [ ! -d "$DATA_DIR" ]; then
    echo "Initializing genesis.json"
    geth --datadir data init /config/genesis.json
fi

echo "Starting geth node"
exec geth "$@"
