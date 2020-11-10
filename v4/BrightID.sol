pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/BrightID/BrightID-SmartContract/blob/master/v4/IBrightID.sol";

contract BrightID is Ownable, IBrightID {

    IERC20 public verifierToken;

    event Verified(address indexed addr);
    event VerifierTokenSet(IERC20 verifierToken);

    struct Verification {
        uint256 time;
        bool isVerified;
    }
    mapping(address => Verification) override public verifications;
    mapping(address => address) override public history;

    function setVerifierToken(IERC20 _verifierToken) public onlyOwner {
        verifierToken = _verifierToken;
        VerifierTokenSet(_verifierToken);
    }

    function verify(
        bytes32 context,
        address[] memory addrs,
        uint timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(verifications[addrs[0]].time < timestamp, "newer verification registered before");

        bytes32 message = keccak256(abi.encodePacked(context, addrs, timestamp));
        address signer = ecrecover(message, v, r, s);
        require(verifierToken.balanceOf(signer) > 0, "not authorized");

        verifications[addrs[0]].time = timestamp;
        verifications[addrs[0]].isVerified = true;
        for(uint i = 1; i < addrs.length; i++) {
            verifications[addrs[i]].time = timestamp;
            verifications[addrs[i]].isVerified = false;
            history[addrs[i - 1]] = addrs[i];
        }
        emit Verified(addrs[0]);
    }

}
