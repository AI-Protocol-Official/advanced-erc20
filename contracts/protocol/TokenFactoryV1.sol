// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../token/AdvancedERC20.sol";
import "../token/ZeppelinERC20.sol";

import "@ai-protocol/access-control-upgradeable/contracts/UpgradeableAccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/**
 * @title Token Deployer
 *
 * @notice A helper stand-alone contract allowing to "clone" an ERC20 Token
 *
 * @dev The deployment is done via EIP-1167 Minimal Proxy Contract
 *      See https://eips.ethereum.org/EIPS/eip-1167
 */
contract TokenFactoryV1 is UpgradeableAccessControl {
	/**
	 * @notice An address of already deployed AdvancedERC20 token used as an implementation
	 */
	address public advancedERC20Address;

	/**
	 * @dev Fired in deployERC20
	 *
	 * @param proxyAddress deployed EIP-1167 clone (proxy) address
	 * @param implAddress ERC20 impl address, always the same
	 * @param name token name to set
	 * @param symbol token symbol to set
	 * @param initialHolder owner of the initial token supply
	 * @param initialSupply initial token supply
	 */
	event ERC20ProxyDeployed(
		address proxyAddress,
		address indexed implAddress,
		string name,
		string symbol,
		address indexed initialHolder,
		uint256 initialSupply
	);

	/**
	 * @dev Deploys a ERC20Deployer instance bound to an already deployed
	 *      ERC20 token instances implementations used to create EIP-1167 "clones"
	 *
	 * @param _advancedERC20Address AdvancedERC20 token instance to bind to
	 */
	function postConstruct(address _advancedERC20Address) public initializer {
		// verify the address is set
		require(_advancedERC20Address != address(0), "zero address");

		// set the address
		advancedERC20Address = _advancedERC20Address;

		// initialize the RBAC module
		_postConstruct(msg.sender, 0);
	}

	/**
	 * @notice "Deploys" AdvancedERC20 token with the specified name, symbol, initial total supply
	 *
	 * @dev Technically this deploys a tiny proxy pointing to the token impl address `advancedERC20Address`
	 *      and initialized it immediately, making the deployment safe and ready for use
	 *
	 * @param _initialHolder owner of the initial token supply
	 * @param _initialSupply initial token supply
	 * @param _name token name to set
	 * @param _symbol token symbol to set
	 */
	function deployAdvancedERC20(
		string memory _name,
		string memory _symbol,
		address _initialHolder,
		uint256 _initialSupply
	) public {
		// "clone" the impl (deploy a proxy)
		address _proxyAddress = Clones.clone(advancedERC20Address);

		// initialize a proxy by invoking the postConstruct
		// factory moves the ownership on the token to the tx executor
		// setup token features to all (0xFFFF)
		AdvancedERC20(_proxyAddress).postConstruct(address(0), _name, _symbol, _initialHolder, _initialSupply, 0xFFFF);

		// emit an event
		emit ERC20ProxyDeployed(
			_proxyAddress,
			advancedERC20Address,
			_name,
			_symbol,
			_initialHolder,
			_initialSupply
		);
	}

	/**
	 * @notice "Deploys" OZ-based basic ZepplinERC20 token with the specified name, symbol, initial total supply
	 *
	 * @param _initialHolder owner of the initial token supply
	 * @param _initialSupply initial token supply
	 * @param _name token name to set
	 * @param _symbol token symbol to set
	 */
	function deployZeppelinERC20(
		string memory _name,
		string memory _symbol,
		address _initialHolder,
		uint256 _initialSupply
	) public {
		// deploy OZ ERC20 impl
		ZeppelinERC20 zeppelinERC20 = new ZeppelinERC20(_name, _symbol, _initialHolder, _initialSupply);

		// emit an event
		emit ERC20ProxyDeployed(
			address(zeppelinERC20),
			address(zeppelinERC20),
			_name,
			_symbol,
			_initialHolder,
			_initialSupply
		);
	}
}
