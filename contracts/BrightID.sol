pragma solidity ^0.4.24;


contract BrightID {

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

    string private constant CONTEXT_NOT_FOUND = "CONTEXT_NOT_FOUND";
    string private constant NODE_NOT_FOUND = "NODE_NOT_FOUND";
    string private constant ALREADY_EXISTS = "ALREADY_EXISTS";
    string private constant OLD_SCORE = "OLD_SCORE";
    string private constant LOWER_SCORE = "Score can't be lower than the existing score.";
    string private constant USER_NOT_FOUND = "USER_NOT_FOUND";
    string private constant SCORE_FOR_CONTEXT_NOT_FOUND = "SCORE_FOR_CONTEXT_NOT_FOUND";
    string private constant CONTEXT_OWNER_ONLY = "CONTEXT_OWNER_ONLY";
    string private constant UNAUTHORIZED_NODE = "UNAUTHORIZED_NODE";
    string private constant BAD_SIGNATURE = "BAD_SIGNATURE";

    /// Events
    event LogSetScore(address userAddress, bytes32 context, uint32 score, uint64 timestamp);
    event LogAddContext(bytes32 indexed context, address indexed owner);
    event LogRemoveContext(bytes32 indexed context, address indexed owner);
    event LogAddNodeToContext(bytes32 indexed context, address nodeAddress);
    event LogRemoveNodeFromContext(bytes32 indexed context, address nodeAddress);

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
     * @param context The context.
     */
    function isContext(bytes32 context)
        public
        view
        returns(bool ret)
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
        returns(bool ret)
    {
        return contexts[context].nodes[nodeAddress];
    }

    /**
     * @notice Set `score` as score for `userAddress` under `context`.
     * @param userAddress The user's address.
     * @param context The context.
     * @param score The user's score.
     * @param timestamp The score's timestamp.
     * @param v signature's v.
     * @param r signature's r.
     * @param s signature's s.
     */
    function setScore(
        address userAddress,
        bytes32 context,
        uint32 score,
        uint64 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
    {
        bytes32 message = keccak256(abi.encode(userAddress, context, score, timestamp));
        address signerAddress = ecrecover(message, v, r, s);
        require(isContext(context), CONTEXT_NOT_FOUND);
        require(signerAddress != address(0), BAD_SIGNATURE);
        require(contexts[context].nodes[signerAddress], UNAUTHORIZED_NODE);
        require(users[userAddress].scores[context].timestamp < timestamp, OLD_SCORE);
        require(score > users[userAddress].scores[context].value, LOWER_SCORE);
        users[userAddress].scores[context].value = score;
        users[userAddress].scores[context].timestamp = timestamp;
        users[userAddress].isActive = true;
        emit LogSetScore(userAddress, context, score, timestamp);
    }

    /**
     * @notice Get `userAddress`'s score in the context.
     * @param userAddress the user's address.
     * @param context the context.
     */
    function getScore(
        address userAddress,
        bytes32 context)
        public
        view
        returns(uint32, uint64)
    {
        require(isUser(userAddress), USER_NOT_FOUND);
        require(users[userAddress].scores[context].timestamp != 0, SCORE_FOR_CONTEXT_NOT_FOUND);
        return (users[userAddress].scores[context].value, users[userAddress].scores[context].timestamp);
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
        emit LogAddContext(context, msg.sender);
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
        emit LogAddNodeToContext(context, nodeAddress);
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
        emit LogRemoveNodeFromContext(context, nodeAddress);
    }

    /**
     * @dev Throws if called by any account other than the owner of the context.
     * @param context The context.
     */
    modifier onlyContextOwner(bytes32 context) {
    	require(contexts[context].owner == msg.sender, CONTEXT_OWNER_ONLY);
        _;
    }
}
