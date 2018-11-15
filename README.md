### Prerequisite:
* python3.5+

### Install Required Modules:

```
npm install -g truffle
npm install -g ganache-cli
pip install pysha3
pip install web3
```

### Run

* run ganache-cli (with test keys) by:

```
cd pytest
./run-ganache-cli.sh
```

* Deploy BrightID smart contract by:

```
truffle deploy --network development --reset
```

* Test with client python script by:

```
python main.py
```
