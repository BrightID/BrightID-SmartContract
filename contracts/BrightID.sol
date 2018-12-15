pragma solidity ^0.4.24;


contract BrightID {

    address public owner;

    struct Score {
        uint32 value;
        uint64 timestamp;
    }

    struct User {
        bool isActive;
        // TODO: Check if it's a proper approach to use bytes32 as mapping key.
        mapping (bytes32 => Score) scores;
    }

    struct Context {
        bool isActive;
        address owner;
        mapping (address => bool) nodes;
    }

    mapping(address => User) private users;
    mapping(bytes32 => Context) private contexts;

    string private constant CONTEXT_NA = "CONTEXT_N/A";
    string private constant NODE_NA = "NODE_N/A";
    string private constant ALREADY_EXISTS = "ALREADY_EXISTS";
    string private constant OLD_SCORE = "OLD_SCORE";
    string private constant USER_NA = "USER_N/A";
    string private constant SCORE_FOR_CONTEXT_NA = "SCORE_FOR_CONTEXT_N/A";
    string private constant CONTEXT_OWNER_ONLY = "CONTEXT_OWNER_ONLY";
    string private constant INCOMPATIBLE_NODE = "INCOMPATIBLE_NODE";
    string private constant BAD_SIGNATURE = "BAD_SIGNATURE";

    /// Events
    event LogSetScore(address userAddress, bytes32 contextName, uint32 score, uint64 timestamp);
    event LogAddContext(bytes32 indexed contextName, address indexed owner);
    event LogRemoveContext(bytes32 indexed contextName, address indexed owner);
    event LogAddNodeToContext(bytes32 indexed contextName, address nodeAddress);
    event LogRemoveNodeFromContext(bytes32 indexed contextName, address nodeAddress);


    /**
     * @notice Check whether `userAddress` is a valid user.
     * @param userAddress The user's address.
     */
    function isUser(address userAddress)
        public
        view
        returns(bool ret)
    {
        return users[userAddress].isActive;
    }

    /**
     * @notice Check whether the context name exists.
     * @param contextName The context's name.
     */
    function isContext(bytes32 contextName)
        public
        view
        returns(bool ret)
    {
        return contexts[contextName].isActive;
    }

    /**
     * @notice Check whether `nodeAddress`'s signature is acceptable for the context.
     * @param contextName The context's name.
     * @param nodeAddress The node's address.
     */
    function isNodeInContext(bytes32 contextName, address nodeAddress)
        public
        view
        returns(bool ret)
    {
        return contexts[contextName].nodes[nodeAddress];
    }

    /**
     * @notice Set `score` as score for `userAddress`.
     * @param userAddress The user's address.
     * @param contextName The context's name.
     * @param score The user's score.
     * @param timestamp The score's timestamp.
     * @param r signature's r.
     * @param s signature's s.
     * @param v signature's v.
     */
    function setScore(
        address userAddress,
        bytes32 contextName,
        uint32 score,
        uint64 timestamp,
        bytes32 r,
        bytes32 s,
        uint8 v)
        public
    {
        address signerAddress = signer(r, s, v, userAddress, score, timestamp);
        require(isContext(contextName), CONTEXT_NA);
        require(signerAddress != address(0), BAD_SIGNATURE);
        require(contexts[contextName].nodes[signerAddress], INCOMPATIBLE_NODE);
        require(users[userAddress].scores[contextName].timestamp < timestamp, OLD_SCORE);
        users[userAddress].scores[contextName].value = score;
        users[userAddress].scores[contextName].timestamp = timestamp;
        users[userAddress].isActive = true;
        emit LogSetScore(userAddress, contextName, score, timestamp);
    }

    /**
     * @notice Get `userAddress`'s score in the context.
     * @param userAddress the user's address.
     * @param contextName the context's name.
     */
    function getScore(
        address userAddress,
        bytes32 contextName)
        public
        view
        returns(uint32, uint64)
    {
        require(isUser(userAddress), USER_NA);
        require(users[userAddress].scores[contextName].timestamp != 0, SCORE_FOR_CONTEXT_NA);
        return (users[userAddress].scores[contextName].value, users[userAddress].scores[contextName].timestamp);
    }

    /**
     * @notice Add a context.
     * @param contextName The context's name.
     */
    function addContext(bytes32 contextName)
        public
    {
        require(contexts[contextName].isActive != true, ALREADY_EXISTS);
        contexts[contextName].isActive = true;
        contexts[contextName].owner = msg.sender;
        emit LogAddContext(contextName, msg.sender);
    }

    /**
     * @notice Remove the context.
     * @param contextName The context's name.
     */
    function removeContext(bytes32 contextName)
        public
        onlyContextOwner(contextName)
    {
        require(isContext(contextName), CONTEXT_NA);
        contexts[contextName].isActive = false;
        emit LogRemoveContext(contextName, msg.sender);
    }

    /**
     * @notice Add `nodeAddress` as a node to the context.
     * @param contextName The context's name.
     * @param nodeAddress The node's address.
     */
    function addNodeToContext(bytes32 contextName, address nodeAddress)
        public
        onlyContextOwner(contextName)
    {
        require(isContext(contextName), CONTEXT_NA);
        require(contexts[contextName].nodes[nodeAddress] != true, ALREADY_EXISTS);
        contexts[contextName].nodes[nodeAddress] = true;
        emit LogAddNodeToContext(contextName, nodeAddress);
    }

    /**
     * @notice Remove `nodeAddress` from the context's nodes.
     * @param contextName The context's name.
     * @param nodeAddress The node's address.
     */
    function removeNodeFromContext(bytes32 contextName, address nodeAddress)
        public
        onlyContextOwner(contextName)
    {
        require(isContext(contextName), CONTEXT_NA);
        require(contexts[contextName].nodes[nodeAddress] == true, NODE_NA);
        contexts[contextName].nodes[nodeAddress] = false;
        emit LogRemoveNodeFromContext(contextName, nodeAddress);
    }

    /**
     * @dev Find the signer of a signature.
     * @param r signature's r.
     * @param s signature's s.
     * @param v signature's v.
     * @param userAddress The user address.
     * @param score The user's score.
     * @param timestamp The score's timestamp.
     */
    function signer(
        bytes32 r,
        bytes32 s,
        uint8 v,
        address userAddress,
        uint32 score,
        uint64 timestamp)
        internal
        pure
        returns(address addr)
    {
        bytes32 message = keccak256(abi.encode(userAddress, score, timestamp));
        return ecrecover(message, v, r, s);
    }

    /**
     * @dev Throws if called by any account other than the owner of the context.
     * @param contextName The context's name.
     */
    modifier onlyContextOwner(bytes32 contextName) {
    	require(contexts[contextName].owner == msg.sender, CONTEXT_OWNER_ONLY);
        _;
    }
}
