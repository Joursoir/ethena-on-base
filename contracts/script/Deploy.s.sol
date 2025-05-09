// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../contracts/USDe.sol";
import "../contracts/EthenaMinting.sol";
import "../contracts/WETH9.sol";
import "../contracts/interfaces/IUSDe.sol";
import "../contracts/interfaces/IWETH9.sol";

contract DeployScript is Script {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant REDEEMER_ROLE = keccak256("REDEEMER_ROLE");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        console.log("Starting deployment from address:", deployer);
        
        WETH9 weth = new WETH9();
        console.log("WETH9 deployed to:", address(weth));

        USDe usde = new USDe(deployer);
        console.log("USDe deployed to:", address(usde));
        
        address[] memory supportedAssets = new address[](1);
        supportedAssets[0] = address(weth);
        address[] memory custodians = new address[](1);
        custodians[0] = deployer;

        uint256 maxMintPerBlock = 1_000_000 * 1e18;
        uint256 maxRedeemPerBlock = 1_000_000 * 1e18;

        EthenaMinting minting = new EthenaMinting(
            IUSDe(address(usde)),
            IWETH9(address(weth)),
            supportedAssets,
            custodians,
            deployer,
            maxMintPerBlock,
            maxRedeemPerBlock
        );
        console.log("EthenaMinting deployed to:", address(minting));

        console.log("Setting up permissions...");
        
        usde.setMinter(address(minting));
        console.log("Minter role set for EthenaMinting on USDe");
        
        minting.grantRole(MINTER_ROLE, deployer);
        minting.grantRole(REDEEMER_ROLE, deployer);
        console.log("Minter and Redeemer roles granted to deployer");
        vm.stopBroadcast();
    
        console.log("\n=== Deployment Summary ===");
        console.log("WETH9:", address(weth));
        console.log("USDe:", address(usde));
        console.log("EthenaMinting:", address(minting));
        console.log("Custodian (deployer):", deployer);
        console.log("Max Mint Per Block:", maxMintPerBlock);
        console.log("Max Redeem Per Block:", maxRedeemPerBlock);
    }
}
