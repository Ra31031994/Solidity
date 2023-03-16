const projectFunding = artifacts.require("projectFunding");
module.exports = function (deployer) {
deployer.deploy(projectFunding);
};