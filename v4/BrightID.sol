pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract BrightID is Ownable {

    IERC20 public verifierToken;

    event Verified(address indexed addr);
    event VerifierTokenSet(IERC20 verifierToken);

    mapping(address => uint) public verifications;
    mapping(address => address) public history;
    mapping(address => bool) public isRevoked;

    function setVerifierToken(IERC20 _verifierToken) public onlyOwner {
        verifierToken = _verifierToken;
        VerifierTokenSet(_verifierToken);
    }

    function verify(
        bytes32 context,
        address addr,
        address[] memory revokeds,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!isRevoked[addr], "address was revoked");
        bytes32 message = keccak256(abi.encodePacked(context, addr, revokeds));
        address signer = ecrecover(message, v, r, s);
        require(verifierToken.balanceOf(signer) > 0, "not authorized");

        verifications[addr] = block.number;
        emit Verified(addr);
        for(uint i = 0; i < revokeds.length; i++) {
            verifications[revokeds[i]] = 0;
            isRevoked[revokeds[i]] = true;
            history[addr] = revokeds[i];
            addr = revokeds[i];
        }
    }
}
