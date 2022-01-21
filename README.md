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

An example--used by [Rare Coin Claims](https://rare.fyi)--to distribute tokens at regular intervals to unique humans. Claimants are allowed to change their address only once per registration period.

## BrightIDSnapshot.sol

The official registry contract used by [Snapshot's BrightID Strategy](https://snapshot.org/#/strategy/brightid). Users are allowed to change their address only once per day.

## IBrightIDSnapshot.sol

An interface modified from [IBrightID.sol](IBrightID.sol) specifically for snapshot to keep backward compatibility on private registries.

## VerifierToken.sol

An ERC-20 token modified from [ERC20PresetMinterPauser.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol). Allowing an admin with the burner role to force burning tokens from other accounts, disqualifies compromised nodes in the process, without the need to redistribute a new token.