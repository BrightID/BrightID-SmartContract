from web3.auto import w3
import json
import requests
import config


def get_nonce(signer):
    data = {
        'jsonrpc': '2.0',
        'method': 'eth_getTransactionCount',
        'params': [signer, "latest"],
        "id": 2
    }
    r = requests.post(config.INFURA_ENDPOINT, data=json.dumps(data))
    nonce = hex2int(r.json()['result'])
    return nonce


def send_eth_call(func_hash):
    print('func_hash', func_hash)
    data = {
        'jsonrpc':
        '2.0',
        'method':
        'eth_call',
        'params': [{
            'from': config.BASE_ACCOUNT,
            'to': config.CONTRACT_ADD,
            'data': func_hash
        }, "latest"],
        "id": 1
    }
    r = requests.post(config.INFURA_ENDPOINT, data=json.dumps(data))
    print(r.json())
    return r.json()['result']


def send_eth_call(data):
    print(data)
    res = w3.eth.call({
        'from': config.BASE_ACCOUNT,
        'to': config.CONTRACT_ADD,
        'data': data
    })
    return res.hex()


def sign_transaction(func_hash, signer_private):
    print('func_hash', func_hash)
    transaction = {
        'to': config.CONTRACT_ADD,
        'value': hex(0),
        'gas': hex(config.GAS),
        'gasPrice': hex(config.GAS_PRICE),
        'nonce': hex(get_nonce()),
        'data': func_hash
    }
    signed = w3.eth.account.signTransaction(transaction, signer_private)
    return signed.rawTransaction.hex()


def send_raw_transaction(raw_transaction):
    data = {
        'jsonrpc': '2.0',
        'method': 'eth_sendRawTransaction',
        'params': [raw_transaction],
        'id': 1
    }
    r = requests.post(config.INFURA_ENDPOINT, data=json.dumps(data))
    print(r.json())
    return r.json()['result']
