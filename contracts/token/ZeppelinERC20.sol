// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20 as OZERC20Impl} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ZeppelinERC20 is OZERC20Impl {
	constructor(
		string memory _name,
		string memory _symbol,
		address _initialHolder,
		uint256 _initialSupply
	) OZERC20Impl(_name, _symbol) {
		_mint(_initialHolder, _initialSupply);
	}
}
