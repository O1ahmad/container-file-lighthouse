<p><img src="https://avatars1.githubusercontent.com/u/12563465?s=200&v=4" alt="OCI logo" title="oci" align="left" height="70" /></p>
<p><img src="https://miro.medium.com/max/300/1*76dYSeZfdwypV1bzlwPivg.gif" alt="Lighthouse logo" title="lighthouse" align="right" height="80" /></p>

Container File ⛵ 🔗 Lighthouse
=========
![GitHub release (latest by date)](https://img.shields.io/github/v/release/0x0I/container-file-lighthouse?color=yellow)
[![0x0I](https://circleci.com/gh/0x0I/container-file-lighthouse.svg?style=svg)](https://circleci.com/gh/0x0I/container-file-lighthouse)
[![Docker Pulls](https://img.shields.io/docker/pulls/0labs/lighthouse?style=flat)](https://hub.docker.com/repository/docker/0labs/lighthouse)
[![License: MIT](https://img.shields.io/badge/License-MIT-blueviolet.svg)](https://opensource.org/licenses/MIT)

Configure and operate Lighthouse: an Ethereum 2.0 client, written in Rust and maintained by Sigma Prime.

**Overview**
  - [Setup](#setup)
    - [Build](#build)
    - [Config](#config)
  - [Operations](#operations)
  - [Examples](#examples)
  - [License](#license)
  - [Author Information](#author-information)

#### Setup
--------------
Guidelines on running service containers are available and organized according to the following software & machine provisioning stages:
* _build_
* _config_
* _operations_

#### Build

##### args

| Name  | description |
| ------------- | ------------- |
| `build_version` | base image to utilize for building application binaries/artifacts |
| `build_type` | type of application build process (i.e. build from *source* or *package*) |
| `lighthouse_version` | `lighthouse` application version to build within image |
| `goss_version` | `goss` testing tool version to install within image test target |
| `version` | container/image infra application version |

```bash
docker build --build-arg <arg>=<value> -t <tag> .
```

##### targets

| Name  | description |
| ------------- | ------------- |
| `builder` | image state following build of lighthouse binary/artifacts |
| `test` | image containing test tools, functional test cases for validation and `release` target contents |
| `release` | minimal resultant image containing service binaries, entrypoints and helper scripts |

```bash
docker build --target <target> -t <tag> .
```

#### Config

:page_with_curl: Configuration of the `lighthouse` client can be expressed as command-line flags passed at runtime. Guidance on and a discussion of the list of configurable settings can be found [here](https://github.com/sigp/lighthouse/issues/1876).

_The following variables can be customized to manage the set of command-line flags specified at startup:_

`$EXTRA_ARGS=<string>` (**default**: `''`)
- space separated list of command-line flags to pass at run-time in addition to the basic lighthouse client commands and sub-commands

  ```bash
  docker run --env EXTRA_ARGS="--network=prater --eth1-endpoints=http://ethereum-rpc.goerli.01labs.net:8545" 0labs/lighthouse:latest lighthouse beacon_node
  ```

###### port mappings

| Port  | mapping description | type | command-line flag |
| :-------------: | :-------------: | :-------------: | :-------------: |
| `9000`    | P2P listening | *TCP*  | `--port` |
| `9000`    | Discovery listening | *UDP*  | `--discovery-port` |
| `5052`    | Beacon node RESTful HTTP API server | *TCP*  | `--http-port` |
| `5054`    | Beacon node Prometheus metrics HTTP server | *TCP*  | `--metrics-port` |
| `5062`    | Validator client RESTful HTTP API server | *TCP*  | `--http-port` |
| `5064`    | Validator client Prometheus metrics HTTP server | *TCP*  | `--metrics-port ` |

###### chain id mappings

| name | command-line flag |
| :---: | :---: |
| Mainnet | `--eth1-endpoint=<mainnet-ethereum-rpc-endpoint (e.g. http://ethereum-rpc.mainnet.01labs.net:8545)>` |
| Goerli | `--eth1-endpoint=<goerli-ethereum-rpc-endpoint (e.g. http://ethereum-rpc.goerli.01labs.net:8545)>` |

**note:** only Eth1 endpoints connected to either Mainnet or the Goerli testnet are supported currently.

#### Operations

:flashlight: To assist with managing a `lighthouse` client and interfacing with the *Ethereum 2.0* network, the following utility functions have been included within the image.

##### Setup deposit accounts and tooling

Download Eth2 deposit CLI tool and setup validator deposit accounts.

`$SETUP_DEPOSIT_CLI=<boolean>` (**default**: `false`)
- whether to download the Eth 2.0 deposit CLI maintained at https://github.com/ethereum/eth2.0-deposit-cli

`$DEPOSIT_CLI_VERSION=<string>` (**default**: `v1.2.0`)
- version of the Eth 2.0 deposit CLI to download

`$ETH2_CHAIN=<string>` (**default**: `mainnet`)
- Ethereum 2.0 chain to register deposit validator accounts and keystores for

`$SETUP_DEPOSIT_ACCOUNTS=<boolean>` (**default**: `false`)
- whether to automatically setup Eth 2.0 validator depositor accounts ([see](https://github.com/ethereum/eth2.0-deposit-cli#step-2-create-keys-and-deposit_data-json) for more details)

`$DEPOSIT_DIR=<path>` (**default**: `/var/tmp/deposit`)
- container directory to generate Eth 2.0 validator deposit keystores

`$DEPOSIT_MNEMONIC_LANG=<string>` (**default**: `english`)
- language to generate deposit mnemonic in 

`$DEPOSIT_NUM_VALIDATORS=<int>` (**default**: `1`)
- count of Eth 2.0 validator deposit keystores to generate

`$DEPOSIT_KEY_PASSWORD=<string>` (**default**: `passw0rd`)
- validator deposit keystore password associated with generated mnemonic

A *validator_keys* directory containing deposit data and the generated validator deposit keystore(s) will be created at the `DEPOSIT_DIR` path.

```bash
ls /var/tmp/deposit/validator_keys
  deposit_data-1632777614.json  keystore-m_12381_3600_0_0_0-1632777613.json
```

##### Query Ethereum standard Beacon Node and Validator Client APIs

Execute a RESTful Lighthouse client HTTP API request.

```
$ lighthouse-helper status api-request --help
Executing entrypoint scripts in /docker-entrypoint.d
Usage: lighthouse-helper status api-request [OPTIONS]

  Execute RESTful API HTTP request

Options:
  --host-addr TEXT   Lighthouse beacon or validator client Eth2 API host
                     address in format <protocol(http/https)>://<IP>:<port>
                     [default: (http://localhost:5052)]
  --api-method TEXT  HTTP method to execute a part of request  [default:
                     (GET)]
  --api-path TEXT    Restful API path to target resource  [default:
                     (lighthouse/syncing)]
  --api-data TEXT    Restful API request body data included within POST
                     requests  [default: ({})]
  --help             Show this message and exit.
```

`$API_HOST_ADDR=<url>` (**default**: `localhost:3501`)
- Prysm Eth2 API host address in format <protocol(http/https)>://<IP>:<port>

`$API_METHOD=<http-method>` (**default**: `GET`)
- HTTP method to execute

`$API_PATH=<url-path>` (**default**: `/lighthouse/syncing`)
- RESTful API path to target resource

`$API_DATA=<json-string>` (**default**: `'{}'`)
- RESTful API request body data included within POST requests

The output consists of a JSON blob corresponding to the expected return object for a given API query. Reference [Lighthouse's client API docs](https://lighthouse-book.sigmaprime.io/api.html) for more details.

###### example

```bash
docker exec lighthouse-beacon lighthouse-helper status api-request --api-path "eth/v1/beacon/headers/head"
{
    "data": {
        "canonical": true,
        "header": {
            "message": {
                "body_root": "0x255c0bdba8efe1627f6d4f817fd5612259895747bbb86fd62acc060400ef5e79",
                "parent_root": "0x1941a37e091704345443b803e122a638af9f706bb6d9cc0e8bcf9a3ef7211e59",
                "proposer_index": "169965",
                "slot": "1514944",
                "state_root": "0x8024d37a937537bb4a2de4e057f1095a3e9fd58c66231bfba274a681b955cc01"
            },
            "signature": "0xb27ef848f6e15c83811cbb5fb8d87282677e987ce61f1115944a44daac4fd5fa759f07b6122d8560f6d04a99b2ba085b0a3039a2eb4937c6f0a4103e0faab9fda21f23757faba9b213fac2b1798476623e82474b782723db3e3c971566d3e051"
            },
        "root": "0xb48063cb0544b3dd102706493328c4ae1d4cc2dd5719bbc92259478d0e782162"
    }
}
```

##### Import validator keystores

Automatically import designated validator keystores and associated wallets on startup.

`$SETUP_VALIDATOR=<boolean>` (**default**: `false`)
- whether to attempt to import validator keystores and associated wallets

`$VALIDATOR_KEYSTORE_PASSWORD=<string>` (**required**)
- password to unlock imported validator keystores

`$VALIDATOR_KEYS_DIR=<directory>` (**default**: `/keys`)
- Path to a directory where keystores to be imported are stored

`$ETH2_CHAIN=<string>` (**default**: `prater`)
- Ethereum 2.0 chain imported keystores are associated with

All imported account keystore details will be created at the default `$HOME/.lighthouse/{network}` directory.

Examples
----------------

* Launch a Lighthouse beacon-chain node connected to the Prater Ethereum 2.0 testnet using a Goerli web3 Ethereum provider:
```
docker run --env EXTRA_ARGS="--network=prater --eth1-endpoints=http://ethereum-rpc.goerli.01labs.net:8545" 0labs/lighthouse:latest lighthouse beacon_node
```

* Customize the beacon chain node deploy container image and host + container data directory:
```
docker run --volume=/my/host/data:/container/data/dir --env EXTRA_ARGS="--datadir=/container/data/dir" 0labs/lighthouse:v2.0.1 lighthouse bn
```

* Install Eth2 deposit CLI tool and automatically setup multiple validator accounts/keys to register on the Prater testnet:
```
# cat .beacon.env
SETUP_DEPOSIT_CLI=true
DEPOSIT_CLI_VERSION=v1.2.0
SETUP_DEPOSIT_ACCOUNTS=true
DEPOSIT_NUM_VALIDATORS=3
ETH2_CHAIN=prater
DEPOSIT_KEY_PASSWORD=ABCabc123!@#$
DEPOSIT_DIR=/deposits

docker run --volume=/host/deposits/data:/deposits --env-file=.beacon.env 0labs/lighthouse:latest ls /deposits
```

* Import one or more EIP-2335 passwords/keys generated by the eth2-deposit-cli Python utility into a Lighthouse VC directory:
```
# cat .validator.env
SETUP_VALIDATOR=true
VALIDATOR_KEYS_DIR=/keys # container path to mounted keys
VALIDATOR_KEYSTORE_PASSWORD=ABCabc123!@#$ # password used to generate Ethereum 2.0 validator deposit keys
ETH2_CHAIN=prater
EXTRA_ARGS="--network=prater"

docker run --volume=/host/deposits/data/validator_keys:/keys --env-file=.validator.env 0labs/lighthouse:latest validator client
```

License
-------

MIT

Author Information
------------------

This Containerfile was created in 2021 by O1.IO.

🏆 **always happy to help & donations are always welcome** 💸

* **ETH (Ethereum):** 0x652eD9d222eeA1Ad843efec01E60C29bF2CF6E4c

* **BTC (Bitcoin):** 3E8gMxwEnfAAWbvjoPVqSz6DvPfwQ1q8Jn

* **ATOM (Cosmos):** cosmos19vmcf5t68w6ug45mrwjyauh4ey99u9htrgqv09
