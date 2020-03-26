import requests
from contracts import config
from contracts import utils
from contracts import brightid

node_address = utils.priv2addr(config.private_key_1)
account2 = utils.priv2addr(config.private_key_2)
account3 = utils.priv2addr(config.private_key_3)

sponsorship_status = {
    0: 'Sponsored',
    1: 'Requested',
    2: 'No Data'
}


def get_verification(context, contextId):
    verification_url = '{0}/brightid4/verifications/{1}/{2}?signed=eth'.format(
        config.BRIGHTID_NODE_URL, context, contextId)
    resp = requests.get(verification_url).json()
    print(resp)
    return resp['data']


def submit_sponsor_request(context, contextId):
    print(
        '\n***** Sponsore {0} in the {1} *****'.format(contextId, context))
    tx = brightid.submitSponsorRequest(
        context, contextId, config.private_key_2)
    print(tx)
    res = brightid.isSponsored(context, contextId)
    print('checking:', sponsorship_status[res])


def start(data, spContextId):
    context = bytes(data['context'], 'ascii')
    contextIds = [bytes(cId, 'ascii') for cId in data['contextIds']]
    spContextId = bytes(spContextId, 'ascii')
    r = '0x' + data['sig']['r']
    s = '0x' + data['sig']['s']
    v = data['sig']['v']

    print('\n***** Add {0} as Context *****'.format(context))
    tx = brightid.addContext(context, config.private_key_2)
    print(tx)
    res = brightid.isContext(context)
    print('checking:', res)

    print(
        '\n***** Add {0} as owner of {1} *****'.format(account3, context))
    tx = brightid.addContextOwner(context, account3, config.private_key_2)
    print(tx)
    res = brightid.isContextOwner(context, account3)
    print('checking:', res)

    print('\n***** Add {0} as node to {1} *****'.format(node_address, context))
    tx = brightid.addNodeToContext(context, node_address, config.private_key_3)
    print(tx)
    res = brightid.isNodeInContext(context, node_address)
    print('checking:', res)

    print(
        '\n***** Remove {0} from owners of {1}*****'.format(account3, context))
    tx = brightid.removeContextOwner(
        context, account3, config.private_key_2)
    print(tx)
    res = brightid.isContextOwner(context, account3)
    print('checking:', not res)

    print('\n***** Register {0} in the {1} *****'.format(account2, context))
    tx = brightid.register(context, contextIds, v, r, s, config.private_key_2)
    print(tx)
    res = brightid.isUniqueHuman(account2, context)
    print('checking:', res)

    submit_sponsor_request(context, spContextId)


if __name__ == '__main__':
    verification_data = get_verification('', '')

    start(verification_data, '')
