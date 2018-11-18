import os
from web3.auto import w3
import config


def get_nonce(signer):
    return w3.eth.getTransactionCount(signer)


def send_eth_call(data):
    res = w3.eth.call({
        'from': config.BASE_ACCOUNT,
        'to': config.CONTRACT_ADD,
        'data': data
    })
    return res.hex()


def send_raw_transaction(raw_transaction):
    res = w3.eth.sendRawTransaction(raw_transaction)
    return res.hex()
