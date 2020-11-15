pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/BrightID/BrightID-SmartContract/blob/master/v4/IBrightID.sol";

contract BrightID is Ownable, IBrightID {
    IERC20 public verifierToken;
    bytes32 public verificationHash;
    bytes32 public context;

    event Verified(address indexed addr);
    event VerifierTokenSet(IERC20 verifierToken);
    event VerificationHashSet(bytes32 verificationHash);
    event ContextSet(bytes32 _context);

    struct Verification {
        uint256 time;
        bool isVerified;
    }
    mapping(address => Verification) public verifications;
    mapping(address => address) override public history;

    /**
     * @param _verificationHash sha256 of the verification expression
     * @param _verifierToken verifier token
     * @param _context BrightID context used for verifying users
     */
    constructor(bytes32 _verificationHash, IERC20 _verifierToken, bytes32 _context) public {
        verificationHash = _verificationHash;
        verifierToken = _verifierToken;
        context = _context;
    }

    /**
     * @notice Set the context
     * @param _context BrightID context used for verifying users
     */
    function setContext(bytes32 _context) public onlyOwner {
        context = _context;
        emit ContextSet(_context);
    }

    /**
     * @notice Set verification hash
     * @param _verificationHash sha256 of the verification expression
     */
    function setVerificationHash(bytes32 _verificationHash) public onlyOwner {
        verificationHash = _verificationHash;
        emit VerificationHashSet(_verificationHash);
    }

    /**
     * @notice Set verifier token
     * @param _verifierToken verifier token
     */
    function setVerifierToken(IERC20 _verifierToken) public onlyOwner {
        verifierToken = _verifierToken;
        emit VerifierTokenSet(_verifierToken);
    }

    /**
     * @notice Register a user by BrightID verification
     * @param addrs The history of addresses used by this user in the context
     * @param timestamp The BrightID node's verification timestamp
     * @param v Component of signature
     * @param r Component of signature
     * @param s Component of signature
     */
    function verify(
        address[] memory addrs,
        uint timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(verifications[addrs[0]].time < timestamp, "newer verification registered before");

        bytes32 message = keccak256(abi.encodePacked(context, addrs, verificationHash, timestamp));
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

    /**
     * @notice Check an address is verified or not
     * @param addr The context id used for verifying users
     */
    function isVerified(address addr) override external view returns (bool) {
        return verifications[user].isVerified;
    }
}
