### Install

Test BrightID Settings App (implemented as an aragon app)
```
npm i -g @aragon/cli
```

Test smart contract with a python client
```
pip install flask
pip install pysha3
pip install web3
```

### Run

```
aragon init BrightID-SmartContract react
git clone https://github.com/BrightID/BrightID-SmartContract.git temp
cp temp/* BrightID-SmartContract/
cd BrightID-SmartContract
aragon run --reset
```

### Test with Python client

* Update `CONTRACT_ADD` in `tests/py/config.py` by address of BrightID App. You can find out address of BrightID App in address bar, when you select BrightID from left menu in Aragon dashboard.
* Test smart contract by running python client script:

```
cd tests/py/
python main.py
```

### Test submitting scores signed by node to smart contract

* Run sample node server by:

```
cd tests/js/
python server.py node_private_key      
```
node_private_key is a private key which is used to sign the score by this sample node server. You should add the address of this private key as node to the context you want sumbit scores to on the BrightID smart contract.

* Then go to `localhost:5555` to submit scores to BrightID smart contract.
* You can use this page to set a custom score for a custom address. You should use a context that the address of node_private_key is added to before.
