pragma solidity ^0.5.0;

import "@openzeppelin/contracts/introspection/ERC165.sol";

contract ERC1238 is ERC165 {

    bool internal _transfersEnabled;

    /*
     *     bytes4(keccak256('transfersEnabled()')) == 0xbef97c87
     */
    bytes4 private constant _INTERFACE_ID_ERC1238 = 0xbef97c87;

    constructor () public {
        // register the supported interfaces to conform to ERC1238 via ERC165
        _registerInterface(_INTERFACE_ID_ERC1238);
    }

    function transfersEnabled() external view returns (bool) {
        return _transfersEnabled;
    }
}
