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
aragon init foo.aragonpm.eth react
git clone https://github.com/BrightID/BrightID-SmartContract.git
cp BrightID-SmartContract/* foo/
cd foo
aragon run
```

### Test with Python client

* Add address of BrightID smart contract to config.py.
* Test with client python script by:

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
