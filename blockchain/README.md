# Forest Simulator

## What we measurement?

- Step to complete suspend certain amount of fund.
- Step to complete suspend relevant transaction.

`NOTE: Response Time, Recovery Time and Post-Incident Analysis`

## Test scenario

- Scenario generate 100,000 transaction suspicious `x` account.
- Scenario generate 100,000 transaction suspicious `x` transaction.
- Scenario generate 100,000 transaction suspicious `x` uncertain amount of each suspicious `x` account.

`geth v1.13.15 is last version that support Proof of Authority.`

simulator provide 2 clients `geth` and `besu`.

# Hardware Specification

CPU: 2 Intel Xeon E5-2650Lv2 (20cores/40threads)  
Memory: 768 GB  
Disk: 1.2 TB SAS HDD with RAID 0

`NOTE: If you use hardware specification lower that this please edit the conf.toml`

## Prerequisite

- docker
- docker-compose
- python3
- pip

Start local network with command.

```shell
./CLIENT/scripts/start.sh
```

Stop local network with command.

```shell
./CLIENT/scripts/stop.sh
```

## Network Configuration

HTTP: `http://localhost:8545`  
API_WS: `ws://localhost:8546`  
CHAIN_ID: `8080`

## Run simulator

with `yarn`

```shell
yarn simulation
```

with `x`

```shell
# command
```

## Reading result

```
# command
```
