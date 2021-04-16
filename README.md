# BrightID-SmartContract

Smart contract templates for publishing BrightID verifications on-chain and using those verifications.

## BrightID.sol

A template contract that can be used to publish BrightID verifications signed by trusted BrightID nodes on-chain.
Apps can query the signed verifications from trusted BrightID nodes using:

`GET /verifications/{context}/{address}?timestamp={seconds/milliseconds}&signed=eth&verification={verification_expresssion}`

and call the `verify` function with the `contextIds`, `timestamp` and `v`, `s` and `s` fields of the `sig` provided in the response.

`verify(address[] memory addrs, uint timestamp, uint8 v, bytes32 r, bytes32 s)`

- Apps should use a `verifier` ERC20 token to be distributed between the addresses used by their trusted nodes to sign verifcations.
The Node One uses `0xb1d71F62bEe34E9Fc349234C201090c33BCdF6DB` to sign verifications so apps should send their verifier token to this address
to be able to use its signatures. The `verifer` token address should be set on the contract by passing to the constructor or `setVerifierToken` function.

- Apps can query customized verifications like `BrightID` or `SeedConnected and Yekta.rank > 2` from BrightID nodes.
  The `sha256` of the verification expression is included in the response as `verificationHash` and should be set on the contract
  by passing to the constructor or `setVerificationHash` function.

## StoppableBrightID.sol

A template contract that can be used to publish BrightID verifications on-chain in a decentralized way.
Using this contract we can define some `supervisor` BrightID nodes that monitor verifications proposed by `proposer` nodes and prevent publishing wrong verifications on the contract by calling `stop` function. This superviosry service can automatically be done using The [BrightID Supervisor](https://github.com/BrightID/BrightID-Supervisor/) service.

## IBrightID.sol

An interface to above verification publishing contracts that different dapps can use to check if an address `isVerified`
and access `history` of addresses used by a single user.

## Distribution.sol

A template contract that show how dapps can use `isVerified` and `history` to distribute a predefined amount of a token between verified BrightID users.

## Sponsor.sol

An interface that should be implemented by dapps that want to sponsor their users on-chain. Such apps should emit the `Sponsor` event in their contracts when
the user had enough interaction to be sponsored in their dapp.

## BrightIDFaucetVerifier.sol

An example--used by [Rare Coin Claims](https://rare.fyi)--to distribute tokens at regular intervals. Claimants are allowed to change their address only once per registration period.
