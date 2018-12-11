from web3.auto import w3

USERS = {
    'user1': {
        'addr': w3.toChecksumAddress('0x8401eb5ff34cc943f096a32ef3d5113febe8d4eb'),
        'private': '0xce8e3bda3b44269c147747a373646393b1504bfcbb73fc9564f5d753d8116608'
    },
    'user2': {
        'addr': w3.toChecksumAddress('0x306469457266cbbe7c0505e8aad358622235e768'),
        'private': '0x8716d2701596f51aa39d061a685d5ae5ec946eb2c7adb059d29024b5bb3b02c8'
    },
    'node1': {
        'addr': w3.toChecksumAddress('0xd873f6dc68e3057e4b7da74c6b304d0ef0b484c7'),
        'private': '0x62d7bb725787d84b059eb4950f6eea060d898183250ca3ea673a36b8e113018f'
    },
    'node2': {
        'addr': w3.toChecksumAddress('0xdcc5dd922fb1d0fd0c450a0636a8ce827521f0ed'),
        'private': '0x705df2ae707e25fa37ca84461ac6eb83eb4921b653e98fdc594b60bea1bb4e52'
    },
}

BASE_ACCOUNT = w3.toChecksumAddress('0xb4124ceb3451635dacedd11767f004d8a28c6ee7')
BASE_ACCOUNT_PRIVATE = '0xa8a54b2d8197bc0b19bb8a084031be71835580a01e70a45a13babd16c9bc1563'

GAS = 2000000
GAS_PRICE = 150*10**9
UNIT = 1.0*10**18
INFURA_ENDPOINT = 'https://ropsten.infura.io/c556c4fcd2d64c41baef3ef84e33052a'
CONTRACT_ADD = w3.toChecksumAddress('0x28bac97a889685fb278cd577b0cd267500c0e478')
