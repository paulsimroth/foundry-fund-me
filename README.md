## Foundry Fund Me

This is a simple contract to enable a user to receive funds from donations.
This project uses foundry.
read the Docs below to get started!

## Foundry Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

Run local tests on Sepolia by forking
```shell
$ forge test --fork-url $SEPOLIA_RPC_URL
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil
Anvil is Foundrys local dev blockchain
```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployFundMe.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### Cast

```shell
$ cast <subcommand>
```