#!/usr/bin/env python
# -*- coding: utf-8 -*-
from flask import Flask, redirect, request
from web3.auto import w3
import sha3
import time
import os
import json
import sys
import string
from shutil import copyfile

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

app = Flask(__name__)
app.secret_key = 'itis secure'


def hex2int(s):
    assert s.startswith('0x')
    return int(s[2:], 16)


def pad32(n):
    return format(n, '064X')


@app.route('/')
def index():
    return redirect('/static/index.html')


@app.route('/sign_score', methods=['POST'])
def sign_score():
    user_addr = request.form['userAddress']
    score = request.form['score']
    timestamp = int(time.time())
    msg = '{0}{1}{2}'.format(
        pad32(hex2int(user_addr)), pad32(int(score)), pad32(timestamp))
    message_hash = sha3.keccak_256(bytes.fromhex(msg)).digest()
    signed_message = w3.eth.account.signHash(
        message_hash, private_key=sys.argv[1])
    return json.dumps({
        'r': '0x' + pad32(signed_message['r']),
        's': '0x' + pad32(signed_message['s']),
        'v': signed_message['v'],
        'timestamp': timestamp,
    })


if __name__ == '__main__':
    copyfile('../../build/contracts/BrightID.json', './static/BrightID.json')
    if not (len(sys.argv) == 2 and sys.argv[1].startswith('0x')
            and all(c in string.hexdigits for c in sys.argv[1][2:])):
        print('''Usage: python server.py node_private_key
            node_private_key is a private key which is used to sign the score by this sample node server.
            node_private_key should be a string in hex format starting by 0x
        ''')
        sys.exit(1)
    app.run(debug=True, host='0.0.0.0', port=5555, threaded=True)