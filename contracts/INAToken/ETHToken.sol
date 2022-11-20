// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ETHFakeToken is ERC20, Ownable {
    constructor() ERC20("ETH Fake Token", "ETH") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}