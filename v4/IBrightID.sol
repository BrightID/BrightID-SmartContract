pragma solidity ^0.6.3;

interface IBrightID {
    event Verified(address indexed addr);
    function verifications(address addr) external returns (uint);
    function history(address addr) external returns (address);
}
