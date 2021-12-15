pragma solidity ^0.6.3;

interface IBrightID {
    event Verified(address indexed addr);
    function isVerified(address addr) external view returns (bool);
}
