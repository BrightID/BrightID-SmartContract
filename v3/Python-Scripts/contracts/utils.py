import os
import sys
from eth_keys import keys
from web3 import Web3, HTTPProvider
from . import config


def get_contracts():
    global contracts
    contracts = {
        'brightid':
        w3.eth.contract(
            address=config.ADDRESSES['brightid'], abi=config.ABIES['brightid']),
    }
    return contracts


def check_account(ctx, param, value):
    if not value and 'CROWDSALE_PRIVATEKEY' in os.environ:
        value = os.environ['CROWDSALE_PRIVATEKEY']
    if not value:
        print(
            'Run:\n\texport CROWDSALE_PRIVATEKEY="your ethereum private key"')
        sys.exit()
    if value.startswith('0x'):
        value = value[2:]
    return value


def priv2addr(private_key):
    pk = keys.PrivateKey(bytes.fromhex(private_key))
    return pk.public_key.to_checksum_address()


def send_transaction(func, value, private_key):
    transaction = func.buildTransaction({
        'nonce':
        w3.eth.getTransactionCount(priv2addr(private_key)),
        'from':
        priv2addr(private_key),
        'value':
        value,
        'gas':
        config.GAS,
        'gasPrice':
        config.GAS_PRICE
    })
    signed = w3.eth.account.signTransaction(transaction, private_key)
    raw_transaction = signed.rawTransaction.hex()
    tx_hash = w3.eth.sendRawTransaction(raw_transaction).hex()
    rec = w3.eth.waitForTransactionReceipt(tx_hash)
    return {'status': rec['status'], 'tx_hash': tx_hash}


def send_eth_call(func, sender=None):
    if not sender:
        sender = current_user()
    result = func.call({
        'from': sender,
    })
    return result


def current_user():
    return priv2addr(config.private_key_2)


def str2bytes32(s):
    assert len(s) <= 32
    padding = (2 * (32 - len(s))) * '0'
    return (bytes(s, 'utf-8')).hex() + padding


def start():
    global contracts, w3
    w3 = Web3(HTTPProvider(config.INFURA_URL))
    get_contracts()


# we are initalizing some variables here
contracts = w3 = None
start()

# FIXME: infura not supports filtering of events.
# Here we are hacking web3.py filters to use getLogs rpc endpoint instead.


def dummy(*args, **argsdic):
    if len(args) > 0 and args[0] == 'eth_newFilter':
        return 0
    else:
        return original_request_blocking(*args, **argsdic)


original_request_blocking = w3.manager.request_blocking
w3.manager.request_blocking = dummy
