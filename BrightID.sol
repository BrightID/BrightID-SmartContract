pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol";
import "./IBrightID.sol";

contract BrightID is Ownable, IBrightID {
    IERC20 public verifierToken;
    bytes32 public app;
    bytes32 public verificationHash;
    bool public useVerificationHash;

    event VerifierTokenSet(IERC20 verifierToken);
    event AppSet(bytes32 _app);
    event VerificationHashSet(bytes32 verificationHash);

    struct Verification {
        uint256 time;
        bool isVerified;
    }
    mapping(address => Verification) public verifications;

    /**
     * @param _verifierToken verifier token
     * @param _app BrightID app used for verifying users
     */
    constructor(IERC20 _verifierToken, bytes32 _app) public {
        verifierToken = _verifierToken;
        app = _app;
    }

    /**
     * @notice Set the app
     * @param _app BrightID app used for verifying users
     */
    function setApp(bytes32 _app) public onlyOwner {
        app = _app;
        emit AppSet(_app);
    }

    /**
     * @notice Set verification hash
     * @param _verificationHash sha256 of the verification expression
     */
    function setVerificationHash(bytes32 _verificationHash) public onlyOwner {
        useVerificationHash = true;
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
     * @param addr The address used by this user in the app
     * @param timestamp The BrightID node's verification timestamp
     * @param v Component of signature
     * @param r Component of signature
     * @param s Component of signature
     */
    function verify(
        address addr,
        uint timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 message;
        if (useVerificationHash) {
            message = keccak256(abi.encodePacked(app, addr, verificationHash, timestamp));
        } else {
            message = keccak256(abi.encodePacked(app, addr, timestamp));
        }
        address signer = ecrecover(message, v, r, s);
        require(verifierToken.balanceOf(signer) > 0, "not authorized");

        verifications[addr].time = timestamp;
        verifications[addr].isVerified = true;
        emit Verified(addr);
    }

    /**
     * @notice Check an address is verified or not
     * @param addr The context id used for verifying users
     */
    function isVerified(address addr) override external view returns (bool) {
        return verifications[addr].isVerified;
    }
}
