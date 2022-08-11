// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "tokens/ERC20Vault.sol";
import "interfaces/ISolidlyPair.sol";
import "interfaces/ISolidlyRouter.sol";
import "interfaces/IVelodromePairFactory.sol";
import "libraries/SolidlyOneSidedVolatile.sol";

contract SolidlyLpWrapper is ERC20Vault {
    ISolidlyPair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    constructor(
        ISolidlyPair _pair,
        string memory _name,
        string memory _symbol,
        uint8 decimals
    ) ERC20Vault(address(_pair), _name, _symbol, decimals) {
        pair = _pair;
        (token0, token1) = _pair.tokens();
    }

    function _beforeHarvest(IVaultHarvester harvester) internal override {
        ISolidlyPair(underlying).claimFees();
        ERC20(token0).transfer(address(harvester), ERC20(token0).balanceOf(address(this)));
        ERC20(token1).transfer(address(harvester), ERC20(token1).balanceOf(address(this)));
    }
}
