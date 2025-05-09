// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../contracts/USDe.sol";
import "../contracts/EthenaMinting.sol";
import "../contracts/WETH9.sol";
import "../contracts/interfaces/IUSDe.sol";
import "../contracts/interfaces/IWETH9.sol";
import "../contracts/interfaces/IEthenaMinting.sol";

contract RedeemUSDeScript is Script {
    address ETHENA_MINTING = vm.envAddress("ETHENA_MINTING_ADDRESS");
    address USDE = vm.envAddress("USDE_ADDRESS");
    address WETH = vm.envAddress("WETH_ADDRESS");

    uint256 ADMIN_PRIVATE_KEY = vm.envUint("ADMIN_PRIVATE_KEY");
    address ADMIN = vm.addr(ADMIN_PRIVATE_KEY);
    uint256 USER_PRIVATE_KEY = vm.envUint("USER_PRIVATE_KEY");
    address USER = vm.addr(USER_PRIVATE_KEY);

    // Redeem the same amount we did in Minting
    uint256 constant collateral_amount = 0.056 ether; 
    uint256 constant usde_amount = 100;

    function run() external {
        vm.startBroadcast(ADMIN_PRIVATE_KEY);
        // Obtain some redemption funds for Custodian (admin)
        IERC20 weth = IERC20(WETH); // workaround to get IRC-20 interface for WETH
        weth.approve(ETHENA_MINTING, collateral_amount);
        console2.log("Admin approved", collateral_amount, "wei for EthenaMinting");
        weth.transfer(ETHENA_MINTING, collateral_amount);
        console2.log("Admin transferred", collateral_amount, "wei to EthenaMinting");
        vm.stopBroadcast();

        vm.startBroadcast(USER_PRIVATE_KEY);
        IERC20 usde = IERC20(USDE);
        uint256 allowanceBefore = usde.allowance(USER, ETHENA_MINTING);
        console2.log("USDe allowance before:", allowanceBefore);
        usde.approve(ETHENA_MINTING, usde_amount);
        uint256 allowanceAfter = usde.allowance(USER, ETHENA_MINTING);
        console2.log("USDe allowance after:", allowanceAfter);

        IEthenaMinting minting = IEthenaMinting(ETHENA_MINTING);
        IEthenaMinting.Order memory order = IEthenaMinting.Order({
            order_type: IEthenaMinting.OrderType.REDEEM,
            expiry: block.timestamp + 10 minutes,
            nonce: 2, // FIXME: Simplified nonce
            benefactor: USER,
            beneficiary: USER,
            collateral_asset: WETH,
            collateral_amount: collateral_amount,
            usde_amount: usde_amount
        });

        // Sign order (EIP-712)
        bytes32 orderHash = minting.hashOrder(order);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_PRIVATE_KEY, orderHash);
        bytes memory sigBytes = abi.encodePacked(r, s, bytes1(v));
        IEthenaMinting.Signature memory signature =
            IEthenaMinting.Signature({signature_type: IEthenaMinting.SignatureType.EIP712, signature_bytes: sigBytes});

        console2.log("Order signed with signature:");
        console2.logBytes(sigBytes);
    
        // At that point we would use Ethena’s public API to get formal
        // RFQ and finally submitting of signed orders.
        // But let's not overcomplicate things for test purpose.
        //
        // https://docs.ethena.fi/api-documentation/overview#orders-submission-endpoint
        vm.stopBroadcast();

        vm.startBroadcast(ADMIN_PRIVATE_KEY);
        // Server will auth our API request, validate data and then submit
        // redeem transaction
        minting.redeem(order, signature);
        console.log("Redeem transaction submitted");

        // We're done. Let's verify balances
        uint256 usdeBalance = usde.balanceOf(USER);
        uint256 wethBalance = weth.balanceOf(USER);
        uint256 mintingWethBalance = weth.balanceOf(ETHENA_MINTING);
        console2.log("\n=== Final Balances ===");
        console2.log("User USDe balance:", usdeBalance);
        console2.log("User WETH balance:", wethBalance);
        console2.log("Minting Contract WETH balance:", mintingWethBalance);
        vm.stopBroadcast();
    }
}