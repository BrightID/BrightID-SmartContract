pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";
import "./ERC1238.sol";

contract BrightID is ERC721Full, ERC1238 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bool internal _transfersEnabled = false;

    uint256 public id;

    struct Context {
        bool isActive;
        address owner;
        mapping(address => bool) nodes;
        mapping(uint256 => address[]) accounts;
        mapping(bytes32 => uint256) cIdToUid;
        mapping(address => uint256) ethToUid;
    }

    mapping(bytes32 => Context) private contexts;

    string private constant DUPLICATE_ETHEREUM_ADDRESS = "Duplicate ethereum address";
    string private constant DUPLICATE_CONTEXT_ID = "Duplicate context id";
    string private constant INVALID_ADDRESS = "Invalid ethereum address";
    string private constant ONLY_CONTEXT_OWNER = "Only context owner";
    string private constant UNAUTHORIZED_NODE = "Unauthorized node";
    string private constant CONTEXT_NOT_FOUND = "Context not found";
    string private constant NODE_NOT_FOUND = "Node not found";
    string private constant ALREADY_EXISTS = "Already exists";
    string private constant BAD_SIGNATURE = "Bad signature";
    string private constant NO_CONTEXT_ID = "No context id";
    string private constant NONTRANSFERRABLE = "Non-transferrable token";

    /// Events
    event ContextAdded(bytes32 indexed context, address indexed owner);
    event NodeToContextAdded(bytes32 indexed context, address nodeAddress);
    event NodeFromContextRemoved(bytes32 indexed context, address nodeAddress);
    event AddressLinked(bytes32 context, bytes32 contextId, address ethAddress);

    constructor()
        ERC721Full("BrightID Verification Badge", "BRIGHTID")
        public
    {
        id = 0;
    }

    /**
     * @notice Check whether the context name exists.
     * @param context The context.
     */
    function isContext(bytes32 context)
        public
        view
        returns(bool)
    {
        return contexts[context].isActive;
    }

    /**
     * @notice Check whether `nodeAddress`'s signature is acceptable for the context.
     * @param context The context.
     * @param nodeAddress The node's address.
     */
    function isNodeInContext(bytes32 context, address nodeAddress)
        public
        view
        returns(bool)
    {
        return contexts[context].nodes[nodeAddress];
    }

    /**
     * @notice get uid.
     * @param context The context.
     * @param cIds an array of contextIds.
     */
    function getUid(bytes32 context, bytes32[] memory cIds)
        internal
        returns(uint256)
    {
        for(uint256 i=1; i < cIds.length-1; i++) {
            uint256 uid = contexts[context].cIdToUid[cIds[i]];
            if (uid != 0) {
                return uid;
            }
        }
        return ++id;
    }

    /**
     * @notice Link `cIds[0]` to `msg.sender` under `context`.
     * @param context The context.
     * @param cIds an array of contextIds.
     * @param v signature's v.
     * @param r signature's r.
     * @param s signature's s.
     */
    function register(
        bytes32 context,
        bytes32[] memory cIds,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
        returns (uint256)
    {
        require(isContext(context), CONTEXT_NOT_FOUND);
        require(0 < cIds.length, NO_CONTEXT_ID);
        require(contexts[context].cIdToUid[cIds[0]] == 0, DUPLICATE_CONTEXT_ID);
        require(contexts[context].ethToUid[msg.sender] == 0, DUPLICATE_ETHEREUM_ADDRESS);

        bytes32 message = keccak256(abi.encodePacked(context, cIds));
        address signerAddress = ecrecover(message, v, r, s);
        require(signerAddress != address(0), BAD_SIGNATURE);
        require(contexts[context].nodes[signerAddress], UNAUTHORIZED_NODE);

        uint256 uid = getUid(context, cIds);

        contexts[context].ethToUid[msg.sender] = uid;

        for(uint256 i=0; i < cIds.length-1; i++) {
            contexts[context].cIdToUid[cIds[i]] = uid;
        }

        // The last member of contexts[context].accounts[uid] is active address of the user
        contexts[context].accounts[uid].push(msg.sender);

        emit AddressLinked(context, cIds[0], msg.sender);

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        return newTokenId;
    }

    /**
     * @notice Check `ethAddress` is unique human.
     * @param ethAddress an Ethereum address.
     * @param context the context.
     */
    function isUniqueHuman(
        address ethAddress,
        bytes32 context)
        public
        view
        returns(bool, address[] memory)
    {
        uint256 uid = contexts[context].ethToUid[ethAddress];
        if (uid != 0) {
            uint256 lastIndex = contexts[context].accounts[uid].length - 1;
            if (contexts[context].accounts[uid][lastIndex] == ethAddress) {
                return(true, contexts[context].accounts[uid]);
            }
        }
    }

    /**
     * @notice Add a context.
     * @param context The context.
     */
    function addContext(bytes32 context)
        public
    {
        require(contexts[context].isActive != true, ALREADY_EXISTS);

        contexts[context].isActive = true;
        contexts[context].owner = msg.sender;
        emit ContextAdded(context, msg.sender);
    }

    /**
     * @notice Add `nodeAddress` as a node to the context.
     * @param context The context.
     * @param nodeAddress The node's address.
     */
    function addNodeToContext(bytes32 context, address nodeAddress)
        public
        onlyContextOwner(context)
    {
        require(isContext(context), CONTEXT_NOT_FOUND);
        require(contexts[context].nodes[nodeAddress] != true, ALREADY_EXISTS);

        contexts[context].nodes[nodeAddress] = true;
        emit NodeToContextAdded(context, nodeAddress);
    }

    /**
     * @notice Remove `nodeAddress` from the context's nodes.
     * @param context The context.
     * @param nodeAddress The node's address.
     */
    function removeNodeFromContext(bytes32 context, address nodeAddress)
        public
        onlyContextOwner(context)
    {
        require(isContext(context), CONTEXT_NOT_FOUND);
        require(contexts[context].nodes[nodeAddress] == true, NODE_NOT_FOUND);

        contexts[context].nodes[nodeAddress] = false;
        emit NodeFromContextRemoved(context, nodeAddress);
    }

    /**
     * @dev Throws if called by any account other than the owner of the context.
     * @param context The context.
     */
    modifier onlyContextOwner(bytes32 context) {
        require(contexts[context].owner == msg.sender, ONLY_CONTEXT_OWNER);
        _;
    }

    function _transferFrom(address /* from */, address /* to */, uint256 /* tokenId */) internal {
        require(_transfersEnabled, NONTRANSFERRABLE);
    }

}