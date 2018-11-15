var HDWalletProvider = require("truffle-hdwallet-provider");
const MNEMONIC = 'tongue estate private mention future crawl water rigid world chaos tube tumble';

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(MNEMONIC, "https://ropsten.infura.io/c556c4fcd2d64c41baef3ef84e33052a")
      },
      network_id: 3,
      gas: 4000000      //make sure this gas allocation isn't over 4M, which is the max
    }
  }
};