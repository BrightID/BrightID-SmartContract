var BrightID = artifacts.require('BrightID.sol');

module.exports = function (deployer) {
  deployer.then(async () => {
    await deployer.deploy(BrightID);
  })
}
