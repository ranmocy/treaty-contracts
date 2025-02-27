// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {LibDiamond} from "contracts/libraries/LibDiamond.sol";
import {IERC173} from "contracts/interfaces/IERC173.sol";

contract OwnershipFacet is IERC173 {
    function transferOwnership(address _newOwner) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
    }

    function owner() external view override returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }
}
