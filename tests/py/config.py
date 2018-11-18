from web3.auto import w3

my_add = {
    'user1': {
        'add': '0xa803a6362E9a1E27bC99e614F97Ff550F695e9D8',
        'p_key': '0x45212ca3fffd8fb88fa366de9a7b6f652a94127d90757fa76e341d5e859e070c'
    },
    'user2': {
        'add': '0x6c8dF581F4F0a530F849EDc86B5F6E3afbaF92e9',
        'p_key': '0xa9709350dc6e4834112365558c97d12e0e4c35d75f4a73dde6b766f7ac3c2428'
    },
    'node1': {
        'add': '0x5DA44C8665Bd2e02abA5D0C097a745eF0Aa4A828',
        'p_key': '0xa947a87c3fe2f5a936c208faa3e8f81ca6c297e588e49c22e2d719f92b6b8806'
    },
    'node2': {
        'add': '0xDbf0b82688d3E9f337EB5b801d0efE4c79ED8e68',
        'p_key': '0x88b30229732cfcfedada8442bd47d67ba5cd93c8ea0a5522c283e8d65869a131'
    },
}

BASE_ACCOUNT = '0x6Acfa47EF099876D4Ed5412460a604aB577B7DE1'
BASE_ACCOUNT_PRIVATE = '0x5020f3c8a872396fa1ff2de62242ac3d5c02161a226cc8b5359c71d1619f531c'

GAS = 2000000
GAS_PRICE = 150*10**9
UNIT = 1.0*10**18
INFURA_ENDPOINT = 'https://ropsten.infura.io/c556c4fcd2d64c41baef3ef84e33052a'
CONTRACT_ADD = w3.toChecksumAddress('0xc1b6afed0672c8bc64e8f5df6dcdc430aab327f9')
