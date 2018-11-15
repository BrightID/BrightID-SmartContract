from web3.auto import w3
import uuid
import time
import sha3
from ganache import *
# from infura import *
import config


def hex2int(s):
    assert s.startswith('0x')
    return int(s[2:], 16)


def pad32(n):
    return format(n, '064X')


def new_address():
    rand_hex = uuid.uuid4().hex
    account = w3.eth.account.create(rand_hex)
    return (account.address, account.privateKey.hex())


def sign_transaction(data, signer, priv):
    transaction = {
        'to': config.CONTRACT_ADD,
        'value': hex(0),
        'gas': hex(config.GAS),
        'gasPrice': hex(config.GAS_PRICE),
        'nonce': hex(get_nonce(signer)),
        'data': data
    }
    signed = w3.eth.account.signTransaction(transaction, priv)
    return signed.rawTransaction.hex()


def is_user(user_add):
    print('isUser:')
    part1 = sha3.keccak_256(b'isUser(address)').hexdigest()[:8]
    part2 = pad32(hex2int(user_add))
    func_hash = '0x{0}{1}'.format(part1, part2)
    result = send_eth_call(func_hash)
    print(hex2int(result) == 1)


def is_node(node_add):
    print('isNode:')
    part1 = sha3.keccak_256(b'isNode(address)').hexdigest()[:8]
    part2 = pad32(hex2int(node_add.lower()))
    func_hash = '0x{0}{1}'.format(part1, part2)
    result = send_eth_call(func_hash)
    print(hex2int(result) == 1)


def is_context(context_name):
    print('isContext:')
    part1 = sha3.keccak_256(b'isContext(bytes32)').hexdigest()[:8]
    part2 = pad32(int.from_bytes(context_name.encode(), 'big'))
    func_hash = '0x{0}{1}'.format(part1, part2)
    result = send_eth_call(func_hash)
    print(hex2int(result) == 1)


def is_node_in_context(context_name, node_add):
    print('isNodeInContext:')
    part1 = sha3.keccak_256(b'isNodeInContext(bytes32,address)').hexdigest()[:8]
    part2 = pad32(int.from_bytes(context_name.encode(), 'big'))
    part3 = pad32(hex2int(node_add))
    func_hash = '0x{0}{1}{2}'.format(part1, part2, part3)
    result = send_eth_call(func_hash)
    print(hex2int(result) == 1)


def add_node(account):
    print('addNode:')
    part1 = sha3.keccak_256(b'addNode(address)').hexdigest()[:8]
    part2 = pad32(hex2int(account)).lower()
    func_hash = '0x{0}{1}'.format(part1, part2)
    raw_transaction = sign_transaction(func_hash, config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    result = send_raw_transaction(raw_transaction)
    print(result)


def remove_node(node_add, node_private):
    print('removeNode:')
    part1 = sha3.keccak_256(b'removeNode(address)').hexdigest()[:8]
    part2 = pad32(hex2int(node_add)).lower()
    func_hash = '0x{0}{1}'.format(part1, part2)
    raw_transaction = sign_transaction(func_hash, node_add, node_private)
    result = send_raw_transaction(raw_transaction)
    print(result)


def add_context(context_name):
    print('addContext:')
    part1 = sha3.keccak_256(b'addContext(bytes32)').hexdigest()[:8]
    part2 = pad32(int.from_bytes(context_name.encode(), 'big'))
    func_hash = '0x{0}{1}'.format(part1, part2)
    raw_transaction = sign_transaction(func_hash, config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    result = send_raw_transaction(raw_transaction)
    print(result)


def remove_context(context_name, owner_add, owner_private):
    print('removeContext:')
    part1 = sha3.keccak_256(b'removeContext(bytes32)').hexdigest()[:8]
    part2 = pad32(int.from_bytes(context_name.encode(), 'big'))
    func_hash = '0x{0}{1}'.format(part1, part2)
    raw_transaction = sign_transaction(func_hash, owner_add, owner_private)
    result = send_raw_transaction(raw_transaction)
    print(result)


def add_node_to_context(context_name, node_add):
    print('addNodeToContext:')
    part1 = sha3.keccak_256(b'addNodeToContext(bytes32,address)').hexdigest()[:8]
    part2 = pad32(int.from_bytes(context_name.encode(), 'big'))
    part3 = pad32(hex2int(node_add)).lower()
    func_hash = '0x{0}{1}{2}'.format(part1, part2, part3)
    raw_transaction = sign_transaction(func_hash, config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    result = send_raw_transaction(raw_transaction)
    print(result)


def remove_node_from_context(context_name, node_add, owner_add, owner_private):
    print('removeNodeFromContext:')
    part1 = sha3.keccak_256(b'removeNodeFromContext(bytes32,address)').hexdigest()[:8]
    part2 = pad32(int.from_bytes(context_name.encode(), 'big'))
    part3 = pad32(hex2int(node_add)).lower()
    func_hash = '0x{0}{1}{2}'.format(part1, part2, part3)
    raw_transaction = sign_transaction(func_hash, owner_add, owner_private)
    result = send_raw_transaction(raw_transaction)
    print(result)


def set_user_score(user_add, context_name, score, timestamp, node_add, node_private):
    print('setScore:')
    msg = '{0}{1}{2}'.format(
        pad32(hex2int(user_add)),
        pad32(score),
        pad32(timestamp))
    message_hash = sha3.keccak_256(bytes.fromhex(msg)).digest()
    signed_message = w3.eth.account.signHash(message_hash, private_key=node_private)
    part1 = sha3.keccak_256(b'setScore(address,bytes32,uint32,uint32,bytes32,bytes32,uint8)').hexdigest()[:8]
    part2 = pad32(hex2int(user_add))
    part3 = pad32(int.from_bytes(context_name.encode(), 'big'))
    part4 = pad32(score)
    part5 = pad32(timestamp)
    part6 = pad32(signed_message['r'])
    part7 = pad32(signed_message['s'])
    part8 = pad32(signed_message['v'])
    data = '0x{0}{1}{2}{3}{4}{5}{6}{7}'.format(part1, part2, part3, part4, part5, part6, part7, part8)
    raw_transaction = sign_transaction(data, node_add, node_private)
    result = send_raw_transaction(raw_transaction)
    print(result)


def get_user_score(user_add, context_name):
    print('getScore:')
    part1 = sha3.keccak_256(b'getScore(address,bytes32)').hexdigest()[:8]
    part2 = pad32(hex2int(user_add)).lower()
    part3 = pad32(int.from_bytes(context_name.encode(), 'big'))
    func_hash = '0x{0}{1}{2}'.format(part1, part2, part3)
    result = send_eth_call(func_hash)
    print(hex2int(result[:66]), hex2int('0x'+result[66:]))


if __name__ == '__main__':
    add_node(config.my_add['node1']['add'])
    time.sleep(1)
    is_node(config.my_add['node1']['add'])
    remove_node(config.my_add['node1']['add'], config.my_add['node1']['p_key'])
    time.sleep(1)
    is_node(config.my_add['node1']['add'])
    add_node(config.my_add['node1']['add'])
    print('*'*50)

    add_context('abram_context')
    time.sleep(1)
    is_context('abram_context')
    remove_context('abram_context', config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    time.sleep(1)
    is_context('abram_context')
    add_context('abram_context')
    print('*'*50)

    add_node_to_context('abram_context', config.my_add['node1']['add'])
    time.sleep(1)
    is_node_in_context('abram_context', config.my_add['node1']['add'])
    remove_node_from_context('abram_context', config.my_add['node1']['add'], config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    time.sleep(1)
    is_node_in_context('abram_context', config.my_add['node1']['add'])
    add_node_to_context('abram_context', config.my_add['node1']['add'])
    print('*'*50)

    set_user_score(config.my_add['user1']['add'], 'abram_context', 63, int(time.time()), config.my_add['node1']['add'], config.my_add['node1']['p_key'])
    time.sleep(1)
    is_user(config.my_add['user1']['add'])
    get_user_score(config.my_add['user1']['add'], 'abram_context')
