import requests
from contracts import config
from contracts import utils
from contracts import brightid

node_address = utils.priv2addr(config.private_key_1)
account2 = utils.priv2addr(config.private_key_2)
account3 = utils.priv2addr(config.private_key_3)


def get_verification(context, contextId):
    verification_url = '{0}/brightid/verifications/{1}/{2}?signed=eth'.format(config.BRIGHTID_NODE_URL, context, contextId)
    resp = requests.get(verification_url).json()
    print(resp)
    return resp['data']


def start(data):
    context = bytes(data['context'], 'ascii')
    contextIds = [bytes(cId, 'ascii') for cId in data['contextIds']]
    r = '0x'+data['sig']['r']
    s = '0x'+data['sig']['s']
    v = data['sig']['v']
    print('\n***** Add {0} as Context *****'.format(context))
    tx = brightid.addContext(context, config.private_key_2)
    print(tx)
    res = brightid.isContext(context)
    print('checking:', res)

    print('\n***** Add {0} as node to {1} *****'.format(node_address, context))
    tx = brightid.addNodeToContext(context, node_address, config.private_key_2)
    print(tx)
    res = brightid.isNodeInContext(context, node_address)
    print('checking:', res)

    print('\n***** Register {0} in the {1} *****'.format(account2, context))
    tx = brightid.register(context, contextIds, v, r, s, config.private_key_2)
    print(tx)
    res = brightid.isUniqueHuman(account2, context)
    print('checking:', res)


if __name__ == '__main__':
    verification_data = get_verification('ethereum', 'c14')
    start(verification_data)