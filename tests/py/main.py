from web3.auto import w3
import uuid
import time
import sha3
from ganache import *
# from infura import *
import config
import random


def hex2int(s):
    assert s.startswith('0x')
    return int(s[2:], 16)


def pad32(n):
    return format(n, '064X')


def str2bytes32(s):
    assert len(s) <= 32
    padding = (2*(32-len(s))) * '0'
    return (bytes(s, 'utf-8')).hex()+padding


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
    print('isUser: {0}'.format(user_add))
    part1 = sha3.keccak_256(b'isUser(address)').hexdigest()[:8]
    part2 = pad32(hex2int(user_add))
    data = '0x{0}{1}'.format(part1, part2)
    result = send_eth_call(data)
    print(hex2int(result) == 1)


def is_context(context_name):
    print('isContext: {0}'.format(context_name))
    part1 = sha3.keccak_256(b'isContext(bytes32)').hexdigest()[:8]
    part2 = str2bytes32(context_name)
    data = '0x{0}{1}'.format(part1, part2)
    result = send_eth_call(data)
    print(hex2int(result) == 1)


def is_node_in_context(context_name, node_addr):
    print('isNodeInContext: "{0}" in "{1}"'.format(node_addr, context_name))
    part1 = sha3.keccak_256(b'isNodeInContext(bytes32,address)').hexdigest()[:8]
    part2 = str2bytes32(context_name)
    part3 = pad32(hex2int(node_addr))
    data = '0x{0}{1}{2}'.format(part1, part2, part3)
    result = send_eth_call(data)
    print(hex2int(result) == 1)


def add_context(context_name):
    print('addContext: {0}'.format(context_name))
    part1 = sha3.keccak_256(b'addContext(bytes32)').hexdigest()[:8]
    part2 = str2bytes32(context_name)
    data = '0x{0}{1}'.format(part1, part2)
    raw_transaction = sign_transaction(data, config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    result = send_raw_transaction(raw_transaction)
    print('tx: {0}'.format(result))


def remove_context(context_name, owner_add, owner_private):
    print('removeContext: {0}'.format(context_name))
    part1 = sha3.keccak_256(b'removeContext(bytes32)').hexdigest()[:8]
    part2 = str2bytes32(context_name)
    data = '0x{0}{1}'.format(part1, part2)
    raw_transaction = sign_transaction(data, owner_add, owner_private)
    result = send_raw_transaction(raw_transaction)
    print('tx: {0}'.format(result))


def add_node_to_context(context_name, node_addr):
    print('addNodeToContext: "{0}" to "{1}"'.format(node_addr, context_name))
    part1 = sha3.keccak_256(b'addNodeToContext(bytes32,address)').hexdigest()[:8]
    part2 = str2bytes32(context_name)
    part3 = pad32(hex2int(node_addr)).lower()
    data = '0x{0}{1}{2}'.format(part1, part2, part3)
    raw_transaction = sign_transaction(data, config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    result = send_raw_transaction(raw_transaction)
    print('tx: {0}'.format(result))


def remove_node_from_context(context_name, node_addr, owner_add, owner_private):
    print('removeNodeFromContext: "{0}" from "{1}"'.format(node_addr, context_name))
    part1 = sha3.keccak_256(b'removeNodeFromContext(bytes32,address)').hexdigest()[:8]
    part2 = str2bytes32(context_name)
    part3 = pad32(hex2int(node_addr)).lower()
    data = '0x{0}{1}{2}'.format(part1, part2, part3)
    raw_transaction = sign_transaction(data, owner_add, owner_private)
    result = send_raw_transaction(raw_transaction)
    print('tx: {0}'.format(result))


def set_user_score(user_add, context_name, score, timestamp, node_addr, node_private):
    print('setScore: "{0}" for "{1}" in "{2}"'.format(score, node_addr, context_name))
    msg = '{0}{1}{2}'.format(
        pad32(hex2int(user_add)),
        pad32(score),
        pad32(timestamp))
    message_hash = sha3.keccak_256(bytes.fromhex(msg)).digest()
    signed_message = w3.eth.account.signHash(message_hash, private_key=node_private)
    part1 = sha3.keccak_256(b'setScore(address,bytes32,uint32,uint32,bytes32,bytes32,uint8)').hexdigest()[:8]
    part2 = pad32(hex2int(user_add))
    part3 = str2bytes32(context_name)
    part4 = pad32(score)
    part5 = pad32(timestamp)
    part6 = pad32(signed_message['r'])
    part7 = pad32(signed_message['s'])
    part8 = pad32(signed_message['v'])
    data = '0x{0}{1}{2}{3}{4}{5}{6}{7}'.format(part1, part2, part3, part4, part5, part6, part7, part8)
    raw_transaction = sign_transaction(data, node_addr, node_private)
    result = send_raw_transaction(raw_transaction)
    print('tx: {0}'.format(result))


def get_user_score(user_add, context_name):
    print('getScore: "{0}" in "{1}"'.format(user_add, context_name))
    part1 = sha3.keccak_256(b'getScore(address,bytes32)').hexdigest()[:8]
    part2 = pad32(hex2int(user_add)).lower()
    part3 = pad32(int.from_bytes(context_name.encode(), 'big'))
    data = '0x{0}{1}{2}'.format(part1, part2, part3)
    result = send_eth_call(data)
    print(hex2int(result[:66]), hex2int('0x'+result[66:]))


def run(context_name):
    add_context(context_name)
    time.sleep(1)
    is_context(context_name)
    remove_context(context_name, config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    time.sleep(1)
    is_context(context_name)
    add_context(context_name)
    print()
    print('#'*20+' Context tests passed '+'#'*20)
    print()

    add_node_to_context(context_name, config.USERS['node1']['addr'])
    time.sleep(1)
    is_node_in_context(context_name, config.USERS['node1']['addr'])
    remove_node_from_context(context_name, config.USERS['node1']['addr'], config.BASE_ACCOUNT, config.BASE_ACCOUNT_PRIVATE)
    time.sleep(1)
    is_node_in_context(context_name, config.USERS['node1']['addr'])
    add_node_to_context(context_name, config.USERS['node1']['addr'])
    print()
    print('#'*20+' Node tests passed '+'#'*20)
    print()

    set_user_score(config.USERS['user1']['addr'], context_name, 63, int(time.time()), config.USERS['node1']['addr'], config.USERS['node1']['private'])
    time.sleep(1)
    is_user(config.USERS['user1']['addr'])
    get_user_score(config.USERS['user1']['addr'], context_name)
    print()
    print('#'*20+' Score tests passed '+'#'*20)
    print()

if __name__ == '__main__':
    context_name = 'context_{}'.format(random.randint(1,1000))
    run(context_name)
