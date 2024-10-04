// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }
    function testBobBalance() public view {
    assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWork() public {
    uint256 initialAllowance = 1000;

    //Bob approves Alice to spend 1000 tokens.
    vm.prank(bob);
    ourToken.approve(alice, initialAllowance);

    uint256 transferAmount = 500;

    vm.prank(alice);
    ourToken.transferFrom(bob, alice, transferAmount);

    assertEq(ourToken.balanceOf(alice), transferAmount);
    assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
    uint256 amount = 1000 * 10 ** 18; // Example amount
    vm.prank(msg.sender);
    ourToken.transfer(bob, amount);

    assertEq(ourToken.balanceOf(bob), amount);
    assertEq(ourToken.balanceOf(msg.sender), deployer.INITIAL_SUPPLY() - amount);
}

function testTransferFrom() public {
    uint256 amount = 500 * 10 ** 18; // Example amount
    vm.prank(msg.sender);
    ourToken.approve(bob, amount);

    vm.prank(bob);
    ourToken.transferFrom(msg.sender, alice, amount);

    assertEq(ourToken.balanceOf(alice), amount);
    assertEq(ourToken.allowance(msg.sender, bob), 0);
}

function testFailTransferExceedsBalance() public {
    uint256 amount = deployer.INITIAL_SUPPLY() + 1;
    vm.prank(msg.sender);
    ourToken.transfer(bob, amount); // This should fail
}

function testFailApproveExceedsBalance() public {
    uint256 amount = deployer.INITIAL_SUPPLY() + 1;
    vm.expectRevert();
    vm.prank(msg.sender);
    ourToken.approve(bob, amount); // This should fail
    }
}