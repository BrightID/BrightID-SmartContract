### Prerequisite:
* python3.5+

### Install Required Modules:

```
npm install -g truffle
npm install -g truffle-hdwallet-provider
npm install -g ganache-cli
pip install flask
pip install pysha3
pip install web3
```

### Run

* run ganache-cli (with test keys) by:

```
cd tests
./run-ganache-cli.sh
```

* Deploy BrightID smart contract by:

```
truffle deploy --network development --reset
```

* Add address of BrightID smart contract to config.py.

* Test with client python script by:

```
python main.py
```
