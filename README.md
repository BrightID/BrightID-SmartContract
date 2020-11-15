# BrightID-SmartContract

Smart contract templates for publishing BrightID verifications on-chain and using those verifications.

## BrightID.sol

A template contract that can be used to publish BrightID verifications signed by BrightID nodes on-chain.
Apps can query the signed verifications from BrightID nodes using:

`GET /verifications/{context}/{address}?timestamp={seconds/milliseconds}&signed=eth&verification={verification_expresssion}`

and call the `verify` function with the `contextIds`, `timestamp` and `v`, `s` and `s` fields of the `sig` provided in the response.

`verify(address[] memory addrs, uint timestamp, uint8 v, bytes32 r, bytes32 s)`

- Apps should use a `verifier` ERC20 token to be distributed between the addresses used by their trusted nodes to sign verifcations.
Node one uses `0xb1d71F62bEe34E9Fc349234C201090c33BCdF6DB` to sign verifications so apps should send their verifier token to this address
to be able to use its signatures. The `verifer` token address should be set on the contract by passing to the constructor or `setVerifierToken` function.

- Apps can query customized verifications like `BrightID` or `SeedConnected and Yekta.rank > 2` from BrightID nodes.
  The `sha256` of the verification expression is included in the response as `verificationHash` and should be set on the contract
  by passing to the constructor or `setVerificationHash` function.

