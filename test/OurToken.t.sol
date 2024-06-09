// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.18;

// import {Test} from "forge-std/Test.sol";
// import {OurToken} from "../src/OurToken.sol";

// import {DeployOurToken} from "../script/DeployOurToken.s.sol";

// contract OurTokenTest is Test {
//     OurToken public ourToken;
//     DeployOurToken public deployer;
//     uint256 public constant STARTING_BALANCE = 100 ether;
//     address bob = makeAddr("bob");
//     address alice = makeAddr("alice");
//     function setUp() public {
        
//         deployer = new DeployOurToken();
//         ourToken = deployer.run();
//         vm.prank(msg.sender);
//         ourToken.transfer(bob, STARTING_BALANCE);
//     }

//     function testBobBalance() public {
//         assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
//     }

//     function testAllowances() public {
//         //transferfrom
//         uint256 initialAllowance = 1000;
//         vm.prank(bob);
//         ourToken.approve(alice, initialAllowance);
//         uint256 transferAmount = 500 ;
//         vm.prank(alice);
//         ourToken.transferFrom(bob, alice, transferAmount);
//         assertEq(ourToken.balanceOf(alice), transferAmount);
//         assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
//     }
   
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    address public alice;
    address public bob;

    function setUp() public {
        DeployOurToken deployer = new DeployOurToken();
        ourToken = OurToken(deployer.run());
        alice = address(0x1);
        bob = address(0x2);
    }

    function testInitialSupply() public {
        uint256 expectedSupply = 10000 * 1e18; // Assuming this is the initial supply set in DeployOurToken
        assertEq(ourToken.totalSupply(), expectedSupply);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        ourToken.mint(address(this), 1);
    }

    function testTransfer() public {
        // Setup: Alice receives some tokens
        vm.prank(address(this));
        ourToken.transfer(alice, 1000);
        assertEq(ourToken.balanceOf(alice), 1000);

        // Alice transfers 200 tokens to Bob
        vm.startPrank(alice);
        ourToken.transfer(bob, 200);
        assertEq(ourToken.balanceOf(bob), 200);
        assertEq(ourToken.balanceOf(alice), 800);
        vm.stopPrank();
    }

    function testApproveAndTransferFrom() public {
        // Setup: Alice approves Bob to spend 300 tokens on her behalf
        vm.prank(alice);
        ourToken.approve(bob, 300);
        assertEq(ourToken.allowance(alice, bob), 300);

        // Bob transfers 200 tokens from Alice to himself
        vm.prank(bob);
        ourToken.transferFrom(alice, bob, 200);
        assertEq(ourToken.balanceOf(bob), 200);
        assertEq(ourToken.allowance(alice, bob), 100);
        assertEq(ourToken.balanceOf(alice), 800); // assuming Alice started with 1000 tokens
    }

    function testFailTransferExceedsBalance() public {
        // Attempt to transfer more tokens than in balance should fail
        vm.startPrank(alice);
        vm.expectRevert();
        ourToken.transfer(bob, 2000); // Assume Alice has less than 2000 tokens
        vm.stopPrank();
    }

    function testFailTransferFromExceedsAllowance() public {
        // Bob tries to transfer more tokens than he's allowed to
        vm.startPrank(bob);
        vm.expectRevert();
        ourToken.transferFrom(alice, bob, 400); // Bob's allowance is only 300
        vm.stopPrank();
    }

    // Additional tests could include more edge cases or behavioral tests,
    // like transfers resulting in zero balances, maximum allowances, etc.
}



