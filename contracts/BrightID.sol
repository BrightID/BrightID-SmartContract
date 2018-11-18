pragma solidity ^0.4.24;


contract BrightID {

    struct Score {
        uint32 value;
        uint32 timestamp;
    }

    struct User {
        bool isActive;
        // TODO: Check if it's a proper approach to use bytes32 as mapping key.
        mapping (bytes32 => Score) scores;
    }

    struct Node {
        bool isActive;
    }

    struct Context {
        bool isActive;
        address owner;
        mapping (address => bool) nodes;
    }

    mapping(address => User) private users;
    mapping(address => Node) private nodes;
    mapping(bytes32 => Context) private contexts;

    event LogSetScore(address userAddress, bytes32 contextName, uint32 score, uint32 timestamp);
    event LogAddNode(address nodeAddress);
    event LogRemoveNode(address nodeAddress);
    event LogAddContext(bytes32 contextName);
    event LogRemoveContext(bytes32 contextName);
    event LogAddNodeToContext(bytes32 contextName, address nodeAddress);
    event LogRemoveNodeFromContext(bytes32 contextName, address nodeAddress);

    constructor()
        public {
            address owner = msg.sender;
            addContext('Aragon');
        }

    /**
     * @dev Check if a user exists.
     * @param userAddress The user's address.
     */
    function isUser(address userAddress)
        public
        constant
        returns(bool ret)
    {
        return users[userAddress].isActive;
    }

    /**
     * @dev Check if a node exists.
     * @param nodeAddress The node's address.
     */
    function isNode(address nodeAddress)
        public
        constant
        returns(bool ret)
    {
        return nodes[nodeAddress].isActive;
    }

    /**
     * @dev Check if a context exists.
     * @param contextName The context's name.
     */
    function isContext(bytes32 contextName)
        public
        constant
        returns(bool ret)
    {
        return contexts[contextName].isActive;
    }

    /**
     * @dev Check each if a node's signature is acceptable for a context.
     * @param contextName The context's name.
     * @param nodeAddress The node's address.
     */
    function isNodeInContext(bytes32 contextName, address nodeAddress)
        public
        constant
        returns(bool ret)
    {
        return contexts[contextName].nodes[nodeAddress];
    }

    /**
     * @dev Set score for user.
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
        uint32 timestamp,
        bytes32 r,
        bytes32 s,
        uint8 v)
        public
    {
        address signerAddress = signer(r, s, v, userAddress, score, timestamp);
        require(isContext(contextName));
        require(contexts[contextName].nodes[signerAddress]);
        require(users[userAddress].scores[contextName].timestamp < timestamp);
        users[userAddress].scores[contextName].value = score;
        users[userAddress].scores[contextName].timestamp = timestamp;
        users[userAddress].isActive = true;
        emit LogSetScore(userAddress, contextName, score, timestamp);
    }

    /**
     * @dev Get user's score.
     * @param userAddress the user's address.
     * @param contextName the context's name.
     */
    function getScore(
        address userAddress,
        bytes32 contextName)
        public
        view
        returns(uint32, uint32)
    {
        require(isUser(userAddress));
        require(users[userAddress].scores[contextName].timestamp != 0);
        return (users[userAddress].scores[contextName].value, users[userAddress].scores[contextName].timestamp);
    }

    /**
     * @dev Add a node.
     * @param nodeAddress The node's address.
     */
    function addNode(address nodeAddress)
        public
    {
        nodes[nodeAddress].isActive = true;
        emit LogAddNode(nodeAddress);
        addNodeToContext('Aragon', nodeAddress);
    }

    /**
     * @dev Remove a node.
     * @param nodeAddress The node's address.
     */
    function removeNode(address nodeAddress)
        public
    {
        require(msg.sender == nodeAddress);
        nodes[nodeAddress].isActive = false;
        emit LogRemoveNode(nodeAddress);
    }

    /**
     * @dev Add a context.
     * @param contextName The context's name.
     */
    function addContext(bytes32 contextName)
        public
    {
        contexts[contextName].isActive = true;
        contexts[contextName].owner = msg.sender;
        emit LogAddContext(contextName);
    }

    /**
     * @dev Remove a context.
     * @param contextName The context's name.
     */
    function removeContext(bytes32 contextName)
        public
    {
        require(msg.sender == contexts[contextName].owner);
        contexts[contextName].isActive = false;
        emit LogRemoveContext(contextName);
    }

    /**
     * @dev Add a node to a context.
     * @param contextName The context's name.
     * @param nodeAddress The node's address.
     */
    function addNodeToContext(bytes32 contextName, address nodeAddress)
        public
    {
        require(isNode(nodeAddress));
        require(isContext(contextName));
        require(contexts[contextName].owner == msg.sender);
        contexts[contextName].nodes[nodeAddress] = true;
        emit LogAddNodeToContext(contextName, nodeAddress);
    }

    /**
     * @dev Remove a node from a context.
     * @param contextName The context's name.
     * @param nodeAddress The node's address.
     */
    function removeNodeFromContext(bytes32 contextName, address nodeAddress)
        public
    {
        require(isContext(contextName));
        require(contexts[contextName].owner == msg.sender);
        if (contexts[contextName].nodes[nodeAddress] = true) {
            contexts[contextName].nodes[nodeAddress] = false;
        }
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
        uint32 timestamp)
        internal
        pure
        returns(address addr)
    {
        bytes32 message = keccak256(abi.encode(userAddress, score, timestamp));
        return ecrecover(message, v, r, s);
    }
}
