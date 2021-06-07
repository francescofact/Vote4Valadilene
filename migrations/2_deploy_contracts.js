var Mayor = artifacts.require("Mayor");
module.exports = function(deployer) {
    deployer.deploy(Mayor, ["0xCC3D33abd97b8a0Fc83489a95Ee8D760a64d3aaA", "0x1860e01f17d3ccB8b95D8f6F044471011c9C0225", "0x4429Ddd735e146Be4064E0744297dAe83BF68d26"], "0x6012c10813778b9Ff7D5275AAcfd49A517f75B59", 3);
};