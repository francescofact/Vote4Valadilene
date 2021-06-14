# Vote4Valadilène
![Banner](repo_banner.png "Banner")

A simple dApp for elections developed for the course "Peer-to-Peer Systems and Blockchain" @ University of Pisa.

## Introduction
Vote4Valadilene (v4v) is a decentralized app that use a smart contract and the Ethereum blockchain to manage the votes of Valadilène and elect its new Mayor.
The app has been developed in Flutter to be deployable to multiple devices at the same time and it has been tested on iOS, Android and Web.

## How to Build and Run
The application needs a RCP Server to comunicate with the blockchain so, one of the first tool we need is Ganache.
Then we need to deploy the Smart Contract on our private blockchain. You can use truffle for this.
Personalize the "migrations/2_deploy_contracts.js" file for your elections and run:
```
truffle migrate
```
After this command the smart contract will be deployed to the blockchain and its address will be visible through Ganache. Copy that address and convert it to a QR code.

To install the app it depends on the system you are using.
