var Mayor = artifacts.require("Mayor");
module.exports = function(deployer) {
    deployer.deploy(Mayor, "0x614D3a138595aD7665040A893667a40BfdEd94C7", "0x5ea79A100cBB8d23cB0456a797411840a8E250E7", 3);
};