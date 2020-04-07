from web3 import Web3
from web3.middleware import geth_poa_middleware
from arango import ArangoClient
from eth_keys import keys
import unittest
import random
import string
import requests
import time
import sys

INFURA_URL = 'wss://rinkeby.infura.io/ws/v3/6a6d1dfc4c414b22ae569334e21ceb76'

try:
    db = ArangoClient().db('_system')
except:
    print('This script should be able to connect to the BrightID Arangodb')
    sys.exit()

w3 = Web3(Web3.WebsocketProvider(INFURA_URL, websocket_kwargs={'timeout': 60}))
if INFURA_URL.count('rinkeby') > 0:
    w3.middleware_onion.inject(geth_poa_middleware, layer=0)


class TestUpdate(unittest.TestCase):

    def __init__(self, *args, **kwargs):
        super(TestUpdate, self).__init__(*args, **kwargs)

        self.PRIVATE_KEY = ''
        self.node_url = 'http://localhost:8529/_db/_system/brightid4/'

        self.idsAsHex = True
        self.USER = 'v7vS3jEqXazNUWj-5QXmrBL8x5XCp3EksF7uVGlijll'

        self.brightid_addr = '0x9A3c23329a02478AAD82383ca5DF419c6c2Ac623'
        self.brightid_abi = '[{"stateMutability": "nonpayable", "inputs": [], "type": "constructor", "payable": false}, {"inputs": [{"indexed": false, "type": "bytes32", "name": "context", "internalType": "bytes32"}, {"indexed": false, "type": "bytes32", "name": "contextId", "internalType": "bytes32"}, {"indexed": false, "type": "address", "name": "ethAddress", "internalType": "address"}], "type": "event", "name": "AddressLinked", "anonymous": false}, {"inputs": [{"indexed": true, "type": "bytes32", "name": "context", "internalType": "bytes32"}, {"indexed": true, "type": "address", "name": "owner", "internalType": "address"}], "type": "event", "name": "ContextAdded", "anonymous": false}, {"inputs": [{"indexed": true, "type": "bytes32", "name": "context", "internalType": "bytes32"}, {"indexed": false, "type": "address", "name": "nodeAddress", "internalType": "address"}], "type": "event", "name": "NodeRemovedFromContext", "anonymous": false}, {"inputs": [{"indexed": true, "type": "bytes32", "name": "context", "internalType": "bytes32"}, {"indexed": false, "type": "address", "name": "nodeAddress", "internalType": "address"}], "type": "event", "name": "NodeAddedToContext", "anonymous": false}, {"inputs": [{"indexed": true, "type": "bytes32", "name": "context", "internalType": "bytes32"}, {"indexed": true, "type": "bytes32", "name": "contextid", "internalType": "bytes32"}], "type": "event", "name": "SponsorshipRequested", "anonymous": false}, {"inputs": [], "constant": true, "name": "id", "outputs": [{"type": "uint256", "name": "", "internalType": "uint256"}], "stateMutability": "view", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}], "constant": true, "name": "isContext", "outputs": [{"type": "bool", "name": "", "internalType": "bool"}], "stateMutability": "view", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}, {"type": "address", "name": "nodeAddress", "internalType": "address"}], "constant": true, "name": "isNodeInContext", "outputs": [{"type": "bool", "name": "", "internalType": "bool"}], "stateMutability": "view", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}, {"type": "bytes32[]", "name": "cIds", "internalType": "bytes32[]"}, {"type": "uint8", "name": "v", "internalType": "uint8"}, {"type": "bytes32", "name": "r", "internalType": "bytes32"}, {"type": "bytes32", "name": "s", "internalType": "bytes32"}], "constant": false, "name": "register", "outputs": [], "stateMutability": "nonpayable", "payable": false, "type": "function"}, {"inputs": [{"type": "address", "name": "ethAddress", "internalType": "address"}, {"type": "bytes32", "name": "context", "internalType": "bytes32"}], "constant": true, "name": "isUniqueHuman", "outputs": [{"type": "bool", "name": "", "internalType": "bool"}, {"type": "address[]", "name": "", "internalType": "address[]"}], "stateMutability": "view", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}, {"type": "bytes32", "name": "contextid", "internalType": "bytes32"}], "constant": false, "name": "sponsor", "outputs": [], "stateMutability": "nonpayable", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}, {"type": "bytes32", "name": "contextid", "internalType": "bytes32"}], "constant": true, "name": "isSponsored", "outputs": [{"type": "uint8", "name": "", "internalType": "enum BrightID.SponsorshipStatus"}], "stateMutability": "view", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}], "constant": false, "name": "addContext", "outputs": [], "stateMutability": "nonpayable", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}, {"type": "address", "name": "nodeAddress", "internalType": "address"}], "constant": false, "name": "addNodeToContext", "outputs": [], "stateMutability": "nonpayable", "payable": false, "type": "function"}, {"inputs": [{"type": "bytes32", "name": "context", "internalType": "bytes32"}, {"type": "address", "name": "nodeAddress", "internalType": "address"}], "constant": false, "name": "removeNodeFromContext", "outputs": [], "stateMutability": "nonpayable", "payable": false, "type": "function"}]'
        self.brightid_contract = w3.eth.contract(
            address=self.brightid_addr, abi=self.brightid_abi)
        self.GAS = 500 * 10**3
        self.GAS_PRICE = 5 * 10**9
        self.CONTEXT = ''.join(random.choices(string.ascii_uppercase, k=5))
        if self.idsAsHex:
            self.CONTEXT_ID = w3.eth.account.create(
                'SIFTALFJAFJMOHSEN').address
        else:
            self.CONTEXT_ID = ''.join(
                random.choices(string.ascii_uppercase, k=15))
        self.users = db.collection('users')
        self.contexts = db.collection('contexts')
        self.sponsorships = db.collection('sponsorships')

    def setUp(self):
        if not self.PRIVATE_KEY:
            print('First set PRIVATE_KEY')
            sys.exit()
        self.contexts.insert({
            '_key': self.CONTEXT,
            'ethName': self.CONTEXT,
            'collection': self.CONTEXT,
            'verification': self.CONTEXT,
            'totalSponsorships': 2,
            'idsAsHex': self.idsAsHex
        })

        self.users.insert({
            '_key': self.USER,
            'verifications': [self.CONTEXT],
        })

        context_collection = db.create_collection(self.CONTEXT)
        context_collection.insert({
            'user': self.USER,
            'contextId': self.CONTEXT_ID,
            'timestamp': int(time.time())
        })

        self.sponsorships.insert({
            '_from': 'users/{}'.format(self.USER),
            '_to': 'contexts/{}'.format(self.CONTEXT)
        })

    def tearDown(self):
        try:
            self.contexts.delete(self.CONTEXT)
        except:
            pass
        try:
            self.users.delete(self.USER)
        except:
            pass
        try:
            db.delete_collection(self.CONTEXT)
        except:
            pass
        try:
            r = self.sponsorships.find(
                {'_from': 'users/{}'.format(self.USER)}).batch()[0]
            self.sponsorships.delete(r['_key'])
        except:
            pass

    def priv2addr(self, private_key):
        pk = keys.PrivateKey(bytes.fromhex(private_key))
        return pk.public_key.to_checksum_address()

    def str2bytes32(self, s):
        assert len(s) <= 32
        padding = (2 * (32 - len(s))) * '0'
        return (bytes(s, 'utf-8')).hex() + padding

    def send_transaction(self, func):
        transaction = func.buildTransaction({
            'nonce': w3.eth.getTransactionCount(
                self.priv2addr(self.PRIVATE_KEY)),
            'from': self.priv2addr(self.PRIVATE_KEY),
            'value': 0,
            'gas': self.GAS,
            'gasPrice': self.GAS_PRICE
        })
        signed = w3.eth.account.sign_transaction(
            transaction, self.PRIVATE_KEY)
        raw_transaction = signed.rawTransaction.hex()
        tx_hash = w3.eth.sendRawTransaction(raw_transaction).hex()
        rec = w3.eth.waitForTransactionReceipt(tx_hash)
        print('status: {0}, tx_hash: {1}\n'.format(rec['status'], tx_hash))
        return {'status': rec['status'], 'tx_hash': tx_hash}

    def add_context(self, context):
        print('Add {} as a context'.format(self.CONTEXT))
        func = self.brightid_contract.functions.addContext(context)
        self.send_transaction(func)

    def add_node_to_context(self, context, node):
        print('Add {} as a node in {}'.format(node, self.CONTEXT))
        func = self.brightid_contract.functions.addNodeToContext(
            context, node)
        self.send_transaction(func)

    def register(self, context, contextIds, v, r, s):
        print('Register {} in {}'.format(
            self.priv2addr(self.PRIVATE_KEY), context))
        func = self.brightid_contract.functions.register(
            context, contextIds, v, r, s)
        self.send_transaction(func)

    def isUniqueHuman(self, ethAddress, context):
        ethAddress = w3.toChecksumAddress(ethAddress)
        resp = self.brightid_contract.functions.isUniqueHuman(
            ethAddress, context).call()
        return resp

    def get_verification(self, context, contextId):
        print('Get verification for the {} in {}\n'.format(contextId, context))

        vurl = '{0}/verifications/{1}/{2}?signed=eth'.format(
            self.node_url, self.CONTEXT, self.CONTEXT_ID)
        resp = requests.get(vurl).json()
        return resp['data']

    def test_register(self):
        self.add_context(self.str2bytes32(self.CONTEXT))

        self.add_node_to_context(self.str2bytes32(
            self.CONTEXT), self.priv2addr(self.PRIVATE_KEY))

        v = self.get_verification(self.CONTEXT, self.CONTEXT_ID)
        bcontext = bytes(v['context'], 'ascii')
        if self.idsAsHex:
            bcontextIds = [bytes.fromhex(
                cId[2:]) + 12 * b'\x00' for cId in v['contextIds']]
        else:
            bcontextIds = [bytes(cId, 'ascii') for cId in v['contextIds']]
        r = '0x' + v['sig']['r']
        s = '0x' + v['sig']['s']
        v = v['sig']['v']

        self.register(bcontext, bcontextIds, v, r, s)

        r = self.isUniqueHuman(self.priv2addr(
            self.PRIVATE_KEY), self.str2bytes32(self.CONTEXT))
        print('result:', r)

        self.assertTrue(r[0])
        self.assertIn(self.priv2addr(self.PRIVATE_KEY), r[1])


if __name__ == '__main__':
    unittest.main()
