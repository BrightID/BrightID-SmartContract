### Install Required Modules:

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

Run sample node server by:

```
cd tests/js/
python server.py
```
Then go to `localhost:5555` to submit scores to BrightID smart contract.
