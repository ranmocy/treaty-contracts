//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibStorage} from "contracts/libraries/Storage.sol";
import {ComponentSpec, GameMode, GameState, Position, ValueType, WorldConstants, QueryCondition, QueryType} from "contracts/libraries/Types.sol";
import {ECSLib} from "contracts/libraries/ECSLib.sol";
import {Templates} from "contracts/libraries/Templates.sol";
import {Set} from "contracts/Set.sol";
import {Component} from "contracts/Component.sol";
import {AddressComponent, BoolComponent, IntComponent, PositionComponent, StringComponent, UintComponent, UintArrayComponent} from "contracts/TypedComponents.sol";
import {CurioERC20} from "contracts/standards/CurioERC20.sol";
import {CurioTreaty} from "contracts/standards/CurioTreaty.sol";
import {Alliance} from "contracts/treaties/Alliance.sol";
import {MercenaryLeague} from "contracts/treaties/MercenaryLeague.sol";
import {TestTreaty} from "contracts/treaties/TestTreaty.sol";
import {NonAggressionPact} from "contracts/treaties/NonAggressionPact.sol";
import {Embargo} from "contracts/treaties/Embargo.sol";
import {CollectiveDefenseFund} from "contracts/treaties/CollectiveDefenseFund.sol";
import {SimpleOTC} from "contracts/treaties/SimpleOTC.sol";
import {HandshakeDeal} from "contracts/treaties/HandshakeDeal.sol";

/// @title Util library
/// @notice Contains all events as well as lower-level setters and getters
/// Util functions generally do not verify correctness of conditions. Make sure to verify in higher-level functions such as those in Engine.
/// Note: This file should not have any occurrences of `msg.sender`. Pass in nation addresses to use them.

library GameLib {
    function gs() internal pure returns (GameState storage) {
        return LibStorage.gameStorage();
    }

    event GamePaused();
    event GameResumed();

    // ----------------------------------------------------------
    // LOGIC SETTERS
    // ----------------------------------------------------------

    function registerComponents(address _gameAddr, ComponentSpec[] memory _componentSpecs) public {
        require(gs().componentNames.length == 0, "CURIO: Components already registered");
        require(_componentSpecs.length > 1, "CURIO: Must have at least 2 components");

        ComponentSpec memory spec;
        address addr;
        uint256 componentID;

        // Register the first component which must be "Address"
        spec = _componentSpecs[0];
        require(spec.valueType == ValueType.ADDRESS && strEq(spec.name, "Address"), "CURIO: First component must be Address");
        addr = address(new AddressComponent(_gameAddr));

        // Record component in GameState
        gs().components[spec.name] = addr;
        gs().componentNames.push(spec.name);

        // Record identifier entity for component
        componentID = ECSLib.addEntity();
        ECSLib.setAddress("Address", componentID, addr);
        uint256 addressComponentID = componentID;

        // Register the rest of the components
        for (uint256 i = 1; i < _componentSpecs.length; i++) {
            spec = _componentSpecs[i];

            // Create corresponding typed component and register its address
            if (spec.valueType == ValueType.ADDRESS) {
                addr = address(new AddressComponent(_gameAddr));
            } else if (spec.valueType == ValueType.BOOL) {
                addr = address(new BoolComponent(_gameAddr));
            } else if (spec.valueType == ValueType.INT) {
                addr = address(new IntComponent(_gameAddr));
            } else if (spec.valueType == ValueType.POSITION) {
                addr = address(new PositionComponent(_gameAddr));
            } else if (spec.valueType == ValueType.STRING) {
                addr = address(new StringComponent(_gameAddr));
            } else if (spec.valueType == ValueType.UINT) {
                addr = address(new UintComponent(_gameAddr));
            } else if (spec.valueType == ValueType.UINT_ARRAY) {
                addr = address(new UintArrayComponent(_gameAddr));
            } else {
                addr = address(new Component(_gameAddr));
            }

            // Record component in GameState
            gs().components[spec.name] = addr;
            gs().componentNames.push(spec.name);

            // Record identifier entity for component
            componentID = ECSLib.addEntity();
            ECSLib.setBool("IsComponent", componentID);
            ECSLib.setAddress("Address", componentID, addr);

            emit ECSLib.NewComponent(spec.name, componentID);
        }

        // Add "IsComponent" to address component
        ECSLib.setBool("IsComponent", addressComponentID);
    }

    function initializeTile(Position memory _startPosition) public returns (uint256) {
        require(isProperTilePosition(_startPosition), "CURIO: Not proper tile position");
        {
            uint256 tileID = getTileAt(_startPosition);
            if (tileID != 0) return tileID;
        }

        // Generate tile address
        address tileAddress = generateNewAddress();

        // Load constants
        uint256 numInitTerrainTypes = gs().worldConstants.numInitTerrainTypes;
        uint256 batchSize = 200 / numInitTerrainTypes;

        // Decode tile terrain
        uint256 tileX = _startPosition.x / gs().worldConstants.tileWidth;
        uint256 tileY = _startPosition.y / gs().worldConstants.tileWidth;
        uint256 encodedCol = gs().encodedColumnBatches[tileX][tileY / batchSize] % (numInitTerrainTypes**((tileY % batchSize) + 1));
        uint256 divFactor = numInitTerrainTypes**(tileY % batchSize);
        uint256 terrain = encodedCol / divFactor;

        // Initialize tile
        uint256 tileID = Templates.addTile(_startPosition, terrain, tileAddress);
        Templates.addInventory(tileID, gs().templates["Guard"]);
        CurioERC20 guardToken = getTokenContract("Guard");

        // Tile can host capital by default
        ECSLib.setBool("CanHostCapital", tileID);

        // Special: battle royale mode center tile initialization
        if (gs().worldConstants.gameMode == GameMode.BATTLE_ROYALE) {
            if (coincident(_startPosition, getMapCenterTilePosition())) {
                // Set map center tile to SUPERTILE of land, no resources, and the top tile strength to start
                uint256 maxTileLevel = (gs().worldConstants.maxCapitalLevel * gs().worldConstants.capitalLevelToEntityLevelRatio) / 2;
                ECSLib.setUint("Terrain", tileID, 0);
                ECSLib.setUint("Level", tileID, maxTileLevel);

                // Drip Guard tokens
                uint256 supertileGuardAmount = getGameParameter("Tile", "Guard", "Amount", "", maxTileLevel);
                guardToken.dripToken(tileAddress, supertileGuardAmount);

                return tileID;
            }
        }

        if (terrain < 3) {
            // Normal tile
            uint256 tileGuardAmount = getGameParameter("Tile", "Guard", "Amount", "", ECSLib.getUint("Level", tileID));
            guardToken.dripToken(tileAddress, tileGuardAmount);
        } else if (terrain == 3 || terrain == 4) {
            // Barbarian tile
            uint256 barbarianLevel = (terrain - 2) * 4;
            ECSLib.setUint("Level", tileID, barbarianLevel);

            uint256 barbarianGuardAmount = getGameParameter("Barbarian", "Guard", "Amount", "", barbarianLevel);
            guardToken.dripToken(tileAddress, barbarianGuardAmount);
        } else {
            // Mountain tile, do nothing
        }

        // Initialize gold mine
        if (terrain == 1 && getResourceAtTile(_startPosition) == 0) {
            Templates.addResource(gs().templates["Gold"], _startPosition, 0);
        }

        // All empty tiles are farms
        if ((terrain == 0 || terrain == 2) && getResourceAtTile(_startPosition) == 0) {
            Templates.addResource(gs().templates["Food"], _startPosition, 0);
        }

        return tileID;
    }

    function removeNation(uint256 _nationID) internal {
        // Remove nation's capital
        uint256 capitalID = getCapital(_nationID);
        ECSLib.removeEntity(capitalID);

        // Remove nation's armies
        uint256[] memory armyIDs = getNationArmies(_nationID);
        for (uint256 i = 0; i < armyIDs.length; i++) {
            ECSLib.removeEntity(armyIDs[i]);
        }

        // Neutralize nation's tiles
        uint256[] memory tileIDs = getNationTiles(_nationID);
        for (uint256 i = 0; i < tileIDs.length; i++) {
            ECSLib.setUint("Nation", tileIDs[i], 0);
        }

        // Remove player address from whitelist
        gs().isWhitelistedByGame[ECSLib.getAddress("Address", _nationID)] = false;

        // Remove nation
        ECSLib.removeEntity(_nationID);
    }

    function endGather(uint256 _armyID) internal {
        // Verify that a gather process is present
        uint256 gatherID = getArmyGather(_armyID);
        require(gatherID != 0, "CURIO: Need to start gathering first");

        // Get army's remaining capacities
        uint256 templateID = ECSLib.getUint("Template", gatherID);
        CurioERC20 resourceToken = CurioERC20(ECSLib.getAddress("Address", templateID));
        address armyAddress = ECSLib.getAddress("Address", _armyID);

        // Gather
        uint256 gatherAmount = (block.timestamp - ECSLib.getUint("InitTimestamp", gatherID)) * getGameParameter("Army", ECSLib.getString("Name", templateID), "Rate", "gather", 0);
        uint256 gatherLoad = (getGameParameter("Troop", "Resource", "Load", "", 0) * getArmyTroopCount(_armyID)) / 1000;
        uint256 armyInventoryBalance = resourceToken.balanceOf(armyAddress);
        resourceToken.dripToken(armyAddress, min(gatherAmount, gatherLoad - armyInventoryBalance));

        ECSLib.removeEntity(gatherID);
    }

    function battleArmy(uint256 _armyID, uint256 _targetArmyID) internal {
        // Verify that army and tar army are adjacent
        require(euclidean(ECSLib.getPosition("Position", _armyID), ECSLib.getPosition("Position", _targetArmyID)) <= ECSLib.getUint("AttackRange", _armyID), "CURIO: Attack out of range");

        // End target army's gather
        if (getArmyGather(_targetArmyID) != 0) endGather(_targetArmyID);

        // Execute one round of battle
        bool victory = attack(_armyID, _targetArmyID, true, true);
        if (!victory) attack(_targetArmyID, _armyID, true, true);
    }

    function battleTile(uint256 _armyID, uint256 _tileID) internal {
        // Verify that army and tile are adjacent
        require(
            euclidean(ECSLib.getPosition("Position", _armyID), getMidPositionFromTilePosition(ECSLib.getPosition("StartPosition", _tileID))) <= ECSLib.getUint("AttackRange", _armyID), //
            "CURIO: Attack out of range"
        );
        // Verify that target tile doesn't have guard left
        address tileAddress = ECSLib.getAddress("Address", _tileID);
        CurioERC20 guardToken = getTokenContract("Guard");
        require(ECSLib.getUint("Amount", getInventory(_tileID, gs().templates["Guard"])) > 0, "CURIO: defender subjugated, claim tile instead");

        // Others cannot attack cities at chaos
        uint256 targetCapitalID = getCapital(ECSLib.getUint("Nation", _tileID));
        capitalSackRecoveryCheck(targetCapitalID);

        // if it is the super tile, check that it's active
        if (coincident(ECSLib.getPosition("StartPosition", _tileID), getMapCenterTilePosition())) {
            require(block.timestamp >= ECSLib.getUint("LastRecovered", _tileID), "Curio: Supertile is not active yet");
        }

        // if it is barbarian, check it's not hybernating
        if (isBarbarian(_tileID)) {
            require(block.timestamp >= ECSLib.getUint("LastRecovered", _tileID), "CURIO: Barbarians hybernating, need to wait");
        }

        // Execute one round of battle
        bool victory = attack(_armyID, _tileID, false, false);
        if (victory) {
            if (coincident(ECSLib.getPosition("StartPosition", targetCapitalID), ECSLib.getPosition("StartPosition", _tileID))) {
                // Victorious against capital, add back some guards for the loser
                guardToken.dripToken(tileAddress, getGameParameter("Tile", "Guard", "Amount", "", ECSLib.getUint("Level", targetCapitalID)));

                // Descend capital into chaos mode
                // 1. Terminate troop production
                // 2. Harvest resources and disable harvest
                // 3. Update `LastSacked` to current timestamp
                uint256 productionID = getBuildingProduction(targetCapitalID);
                if (productionID != 0) ECSLib.removeEntity(productionID);

                uint256 chaosDuration = getGameParameter("Capital", "", "Cooldown", "Chaos", ECSLib.getUint("Level", targetCapitalID));
                ECSLib.setUint("LastHarvested", targetCapitalID, block.timestamp + chaosDuration);

                ECSLib.setUint("LastSacked", targetCapitalID, block.timestamp);
            } else {
                if (isBarbarian(_tileID)) {
                    // Reset barbarian
                    distributeBarbarianReward(GameLib.getCapital(ECSLib.getUint("Nation", _armyID)), _tileID);
                    uint256 barbarianGuardAmount = getGameParameter("Barbarian", "Guard", "Amount", "", ECSLib.getUint("Level", _tileID));
                    ECSLib.setUint("LastRecovered", _tileID, block.timestamp + getGameParameter("Barbarian", "", "Cooldown", "", 0));
                    guardToken.dripToken(tileAddress, barbarianGuardAmount);
                } else {
                    // Neutralize tile & resource
                    uint256 resourceID = getResourceAt(ECSLib.getPosition("StartPosition", _tileID));
                    ECSLib.setUint("Nation", _tileID, 0);
                    ECSLib.setUint("Nation", resourceID, 0);
                }
            }
        } else {
            attack(_tileID, _armyID, false, true);
        }
    }

    function attack(
        uint256 _offenderID,
        uint256 _defenderID,
        bool _transferResourcesUponVictory,
        bool _removeUponVictory
    ) internal returns (bool victory) {
        uint256[] memory troopTemplateIDs = ECSLib.getStringComponent("Tag").getEntitiesWithValue(string("TroopTemplate"));
        victory = true;

        // Offender attacks defender
        {
            uint256 loss;
            for (uint256 j = 0; j < troopTemplateIDs.length; j++) {
                uint256 defenderTroopInventoryID = getInventory(_defenderID, troopTemplateIDs[j]);
                if (ECSLib.getUint("Amount", defenderTroopInventoryID) == 0) continue;

                for (uint256 i = 0; i < troopTemplateIDs.length; i++) {
                    uint256 offenderTroopAmount = ECSLib.getUint("Amount", getInventory(_offenderID, troopTemplateIDs[i]));
                    if (offenderTroopAmount == 0) continue;

                    {
                        uint256 troopTypeBonus = getAttackBonus(troopTemplateIDs[i], troopTemplateIDs[j]);
                        loss =
                            (troopTypeBonus * (sqrt(offenderTroopAmount) * ECSLib.getUint("Attack", troopTemplateIDs[i]) * 2)) / //
                            (ECSLib.getUint("Defense", troopTemplateIDs[j]) * ECSLib.getUint("Health", troopTemplateIDs[j]));
                    }

                    loss = min(loss, ECSLib.getUint("Amount", defenderTroopInventoryID));
                    CurioERC20(ECSLib.getAddress("Address", troopTemplateIDs[j])).destroyToken(ECSLib.getAddress("Address", _defenderID), loss);
                }

                if (ECSLib.getUint("Amount", defenderTroopInventoryID) > 0) victory = false;
            }
        }

        if (victory) {
            if (_transferResourcesUponVictory) {
                // Offender takes defender's resources
                uint256[] memory resourceTemplateIDs = ECSLib.getStringComponent("Tag").getEntitiesWithValue(string("ResourceTemplate"));
                for (uint256 i = 0; i < resourceTemplateIDs.length; i++) {
                    CurioERC20 resourceToken = CurioERC20(ECSLib.getAddress("Address", resourceTemplateIDs[i]));
                    resourceToken.transferAll(ECSLib.getAddress("Address", _defenderID), ECSLib.getAddress("Address", _offenderID));
                }
            }

            if (_removeUponVictory) {
                // Defender (always army here) is dealt with same as in disband
                ECSLib.removeEntity(_defenderID);
            }
        }
    }

    function battleOnce(
        uint256 _keeperIdA,
        uint256 _keeperIdB,
        bool _transferResourcesUponVictory,
        bool _removeUponVictory
    ) internal returns (bool victory) {
        victory = attack(_keeperIdA, _keeperIdB, _transferResourcesUponVictory, _removeUponVictory);
        if (!victory) attack(_keeperIdB, _keeperIdA, _transferResourcesUponVictory, _removeUponVictory);
    }

    function distributeBarbarianReward(uint256 _capitalID, uint256 _barbarianTileID) internal {
        uint256 barbarianLevel = ECSLib.getUint("Level", _barbarianTileID);
        uint256[] memory resourceTemplateIDs = ECSLib.getStringComponent("Tag").getEntitiesWithValue(string("ResourceTemplate"));

        for (uint256 i = 0; i < resourceTemplateIDs.length; i++) {
            uint256 rewardAmount = getGameParameter("Barbarian", ECSLib.getString("Name", resourceTemplateIDs[i]), "Reward", "", barbarianLevel);

            CurioERC20 resourceToken = CurioERC20(ECSLib.getAddress("Address", resourceTemplateIDs[i]));
            resourceToken.dripToken(ECSLib.getAddress("Address", _capitalID), rewardAmount);
        }
    }

    function unloadResources(address _nationAddress, address _armyAddress) internal {
        uint256[] memory resourceTemplateIDs = ECSLib.getStringComponent("Tag").getEntitiesWithValue(string("ResourceTemplate"));

        for (uint256 i = 0; i < resourceTemplateIDs.length; i++) {
            CurioERC20 resourceToken = CurioERC20(ECSLib.getAddress("Address", resourceTemplateIDs[i]));
            resourceToken.transferAll(_armyAddress, _nationAddress);
        }
    }

    function disbandArmy(address _nationAddress, address _armyAddress) internal {
        uint256[] memory troopTemplateIDs = ECSLib.getStringComponent("Tag").getEntitiesWithValue(string("TroopTemplate"));

        for (uint256 i = 0; i < troopTemplateIDs.length; i++) {
            CurioERC20 resourceToken = CurioERC20(ECSLib.getAddress("Address", troopTemplateIDs[i]));
            resourceToken.transferAll(_armyAddress, _nationAddress);
        }
    }

    function delegateGameFunction(
        uint256 _nationID,
        string memory _functionName,
        uint256 _delegateID,
        uint256 _subjectID,
        bool _canCall
    ) internal {
        // Get current delegation
        uint256[] memory delegationIDs = getDelegations(_functionName, _nationID, _delegateID);

        // Case I: Entity-agnostic delegation
        if (_subjectID == 0) {
            // Remove all delegations
            for (uint256 i = 0; i < delegationIDs.length; i++) {
                ECSLib.removeEntity(delegationIDs[i]);
            }
            if (_canCall) {
                // Delegate all
                Templates.addDelegation(_functionName, _nationID, _delegateID, 0);
            }
            return;
        }

        // Case II: Entity-specific delegation
        bool delegationExists;
        uint256 delegationID;
        for (uint256 i = 0; i < delegationIDs.length; i++) {
            uint256 subjectID = ECSLib.getUint("Subject", delegationIDs[i]);
            if (subjectID == 0 || subjectID == _subjectID) {
                delegationExists = true;
                if (subjectID == _subjectID) delegationID = delegationIDs[i];
            }
        }

        // Update delegation
        if (_canCall && !delegationExists && delegationID == 0) {
            Templates.addDelegation(_functionName, _nationID, _delegateID, _subjectID);
        } else if (!_canCall && delegationID != 0) {
            ECSLib.removeEntity(delegationID);
        } else if (!_canCall && delegationExists) {
            revert("CURIO: Need to revoke entity-agnostic delegation");
        }
    }

    function deployTreaty(uint256 _nationID, string memory _treatyName) internal returns (address treatyAddress) {
        // Deploy treaty
        if (GameLib.strEq(_treatyName, "Alliance")) {
            treatyAddress = address(new Alliance(address(this)));
        } else if (GameLib.strEq(_treatyName, "Test Treaty")) {
            treatyAddress = address(new TestTreaty(address(this)));
        } else if (GameLib.strEq(_treatyName, "Non-Aggression Pact")) {
            treatyAddress = address(new NonAggressionPact(address(this)));
        } else if (GameLib.strEq(_treatyName, "Embargo")) {
            treatyAddress = address(new Embargo(address(this)));
        } else if (GameLib.strEq(_treatyName, "Collective Defense Fund")) {
            treatyAddress = address(new CollectiveDefenseFund(address(this)));
        } else if (GameLib.strEq(_treatyName, "Simple OTC Trading Agreement")) {
            treatyAddress = address(new SimpleOTC(address(this)));
        } else if (GameLib.strEq(_treatyName, "Handshake Deal")) {
            treatyAddress = address(new HandshakeDeal(address(this)));
        } else if (GameLib.strEq(_treatyName, "Mercenary League")) {
            treatyAddress = address(new MercenaryLeague(address(this)));
        } else {
            revert("CURIO: Unsupported treaty name");
        }

        // Register treaty
        uint256 treatyTemplateID = gs().templates[_treatyName];
        Templates.addTreaty(
            treatyAddress, // STYLE: DO NOT REMOVE THIS COMMENT
            ECSLib.getString("Name", treatyTemplateID),
            ECSLib.getString("Description", treatyTemplateID),
            ECSLib.getString("ABIHash", treatyTemplateID),
            ECSLib.getString("Metadata", treatyTemplateID),
            _nationID
        );
    }

    function setGameParameter(string memory _identifier, uint256 _value) internal {
        uint256[] memory res = ECSLib.getStringComponent("Tag").getEntitiesWithValue(_identifier);
        require(res.length > 0, "CURIO: You must add game parameter first");
        uint256 parameterID = res[0];

        ECSLib.setUint("Amount", parameterID, _value);
    }

    // ----------------------------------------------------------
    // LOGIC GETTERS
    // ----------------------------------------------------------

    /// @dev Hardcoded triangular relations for troop attack bonuses
    function getAttackBonus(uint256 _offenderTemplateID, uint256 _defenderTemplateID) internal view returns (uint256) {
        uint256 horsemanTemplateId = gs().templates["Horseman"];
        uint256 warriorTemplateId = gs().templates["Warrior"];
        uint256 slingerTemplateId = gs().templates["Slinger"];

        if (_offenderTemplateID == horsemanTemplateId) {
            if (_defenderTemplateID == warriorTemplateId) return 60;
            if (_defenderTemplateID == slingerTemplateId) return 140;
            else return 100;
        } else if (_offenderTemplateID == warriorTemplateId) {
            if (_defenderTemplateID == slingerTemplateId) return 60;
            if (_defenderTemplateID == horsemanTemplateId) return 140;
            else return 100;
        } else if (_offenderTemplateID == slingerTemplateId) {
            if (_defenderTemplateID == horsemanTemplateId) return 60;
            if (_defenderTemplateID == warriorTemplateId) return 140;
            else return 100;
        } else return 100;
    }

    function getTokenContract(string memory _tokenName) internal view returns (CurioERC20) {
        uint256 tokenTemplateID = gs().templates[_tokenName];
        require(tokenTemplateID != 0, "CURIO: Token template not found");

        return CurioERC20(ECSLib.getAddress("Address", tokenTemplateID));
    }

    function getEntityByAddress(address _entityAddress) internal view returns (uint256) {
        uint256[] memory res = AddressComponent(gs().components["Address"]).getEntitiesWithValue(_entityAddress);

        require(res.length <= 1, "CURIO: Found more than one entity");
        return res.length == 1 ? res[0] : 0;
    }

    function getInventoryIDLoadAndBalance(address _entityAddress, string memory _resourceType)
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 entityID = ECSLib.getAddressComponent("Address").getEntitiesWithValue(_entityAddress)[0];
        uint256 templateID = gs().templates[_resourceType];
        string memory entityTag = ECSLib.getString("Tag", entityID);

        // Fetch load for given template
        uint256 load;
        if (strEq(entityTag, "Army")) {
            uint256 capitalID = getCapital(ECSLib.getUint("Nation", entityID));
            if (templateID == gs().templates["Horseman"] || templateID == gs().templates["Warrior"] || templateID == gs().templates["Slinger"]) {
                load = getGameParameter(ECSLib.getString("Tag", entityID), "Troop", "Amount", "", ECSLib.getUint("Level", capitalID));
            } else if (templateID == gs().templates["Food"] || templateID == gs().templates["Gold"]) {
                load = ECSLib.getUint("Load", entityID);
            } else if (templateID == gs().templates["Guard"]) {
                load = 0;
            } else {
                revert("CURIO: Unsupported template");
            }
        } else if (strEq(entityTag, "Building") && strEq(ECSLib.getString("BuildingType", entityID), "Capital")) {
            // Set to max uint256
            load = 2**256 - 1;
        } else if (strEq(entityTag, "Tile")) {
            load = getGameParameter("Tile", "Guard", "Amount", "", ECSLib.getUint("Level", entityID));
        } else if (strEq(entityTag, "Treaty")) {
            load = 2**256 - 1;
        } else {
            revert(string.concat("CURIO: Unsupported keeper '", entityTag, "'"));
        }

        // Fetch inventoryID, and create if not found
        uint256 inventoryID = getInventory(entityID, templateID);
        if (inventoryID == 0) inventoryID = Templates.addInventory(entityID, templateID);

        // Fetch balance
        uint256 balance = ECSLib.getUint("Amount", inventoryID);

        return (inventoryID, load, balance);
    }

    function getAllowance(
        uint256 _templateID,
        uint256 _ownerID,
        uint256 _spenderID
    ) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](4);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Allowance"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Template"]), abi.encode(_templateID));
        query[2] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Owner"]), abi.encode(_ownerID));
        query[3] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Caller"]), abi.encode(_spenderID));

        uint256[] memory allowanceIDs = ECSLib.query(query);
        require(allowanceIDs.length <= 1, "CURIO: Found more than one allowance");
        return allowanceIDs.length == 1 ? allowanceIDs[0] : 0;
    }

    function getTreatySignatures(uint256 _treatyID) internal view returns (uint256[] memory) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Signature"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Treaty"]), abi.encode(_treatyID));
        return ECSLib.query(query);
    }

    function getTreatySigners(uint256 _treatyID) internal view returns (uint256[] memory) {
        uint256[] memory signatureIDs = getTreatySignatures(_treatyID);

        uint256[] memory signerIDs = new uint256[](signatureIDs.length);
        for (uint256 i = 0; i < signatureIDs.length; i++) {
            signerIDs[i] = ECSLib.getUint("Nation", signatureIDs[i]);
        }

        return signerIDs;
    }

    function getNationSignatures(uint256 _nationID) internal view returns (uint256[] memory) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Signature"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Nation"]), abi.encode(_nationID));
        return ECSLib.query(query);
    }

    function getSignedTreaties(uint256 _nationID) internal view returns (uint256[] memory) {
        uint256[] memory signatureIDs = getNationSignatures(_nationID);

        uint256[] memory treatyIDs = new uint256[](signatureIDs.length);
        for (uint256 i = 0; i < signatureIDs.length; i++) {
            treatyIDs[i] = ECSLib.getUint("Treaty", signatureIDs[i]);
        }

        return treatyIDs;
    }

    function getSignedTreatyAddresses(uint256 _nationID) internal view returns (address[] memory) {
        uint256[] memory signatureIDs = getNationSignatures(_nationID);

        address[] memory treatyAddresses = new address[](signatureIDs.length);
        for (uint256 i = 0; i < signatureIDs.length; i++) {
            treatyAddresses[i] = ECSLib.getAddress("Address", ECSLib.getUint("Treaty", signatureIDs[i]));
        }

        return treatyAddresses;
    }

    function getNationTreatySignature(uint256 _nationID, uint256 _treatyID) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](3);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Signature"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Nation"]), abi.encode(_nationID));
        query[2] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Treaty"]), abi.encode(_treatyID));

        uint256[] memory res = ECSLib.query(query);
        return res.length == 1 ? res[0] : 0;
    }

    function getNationTiles(uint256 _nationID) internal view returns (uint256[] memory) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Nation"]), abi.encode(_nationID));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Tile"));
        return ECSLib.query(query);
    }

    function getNationArmies(uint256 _nationID) internal view returns (uint256[] memory) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Nation"]), abi.encode(_nationID));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Army"));
        return ECSLib.query(query);
    }

    function getArmiesAtTile(Position memory _startPosition) internal view returns (uint256[] memory) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.Has, Component(gs().components["Speed"]), new bytes(0));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["StartPosition"]), abi.encode(_startPosition));
        return ECSLib.query(query);
    }

    function getArmyTroopCount(uint256 _armyID) internal view returns (uint256) {
        uint256 count = 0;
        uint256[] memory troopTemplateIDs = ECSLib.getStringComponent("Tag").getEntitiesWithValue(string("TroopTemplate"));
        for (uint256 i = 0; i < troopTemplateIDs.length; i++) {
            uint256 inventoryID = getInventory(_armyID, troopTemplateIDs[i]);
            count += ECSLib.getUint("Amount", inventoryID);
        }
        return count;
    }

    function getGameParameter(
        string memory _subject,
        string memory _object,
        string memory _componentName,
        string memory _functionName,
        uint256 _level
    ) internal view returns (uint256) {
        string memory identifier = string(abi.encodePacked(_subject, "-", _object, "-", _componentName, "-", _functionName, "-", Strings.toString(_level)));
        uint256[] memory res = ECSLib.getStringComponent("Tag").getEntitiesWithValue(identifier);
        // require(res.length <= 1, string(abi.encodePacked("CURIO: Constant with Tag=", identifier, " duplicated")));
        require(res.length >= 1, string(abi.encodePacked("CURIO: Constant with Tag=", identifier, " not found")));
        return ECSLib.getUint("Amount", res[0]);
    }

    function getTreatyByName(string memory _name) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Treaty"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Name"]), abi.encode(_name));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Treaty assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getTreatyWhitelisted(uint256 _nationID, uint256 _treatyID) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](3);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("TreatyWhitelisted"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Nation"]), abi.encode(_nationID));
        query[2] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Treaty"]), abi.encode(_treatyID));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Treaty assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getBuildingProduction(uint256 _buildingID) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Keeper"]), abi.encode(_buildingID));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("TroopProduction"));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Production assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getArmyGather(uint256 _armyID) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Army"]), abi.encode(_armyID));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("ResourceGather"));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Gather assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getResourceAtTile(Position memory _startPosition) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode(string("Resource")));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["StartPosition"]), abi.encode(_startPosition));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Tile resource assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getMovableEntityAt(Position memory _position) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.Has, Component(gs().components["Speed"]), new bytes(0));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Position"]), abi.encode(_position));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Movable entity assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getArmyAt(Position memory _position) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode(string("Army")));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Position"]), abi.encode(_position));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Army assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getCapitalAtTile(Position memory _startPosition) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Capital"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["StartPosition"]), abi.encode(_startPosition));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Tile capital assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getInventory(uint256 _keeperID, uint256 _templateID) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](3);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Inventory"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Keeper"]), abi.encode(_keeperID));
        query[2] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Template"]), abi.encode(_templateID));
        uint256[] memory res = ECSLib.query(query);

        require(res.length <= 1, "CURIO: Inventory assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getArmiesFromNation(uint256 _nationID) internal view returns (uint256[] memory) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Army"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Nation"]), abi.encode(_nationID));
        return ECSLib.query(query);
    }

    function getCapital(uint256 _nationID) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Nation"]), abi.encode(_nationID));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["BuildingType"]), abi.encode("Capital"));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Capital assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getTileAt(Position memory _startPosition) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["StartPosition"]), abi.encode(_startPosition));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Tile"));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Tile assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getResourceAt(Position memory _startPosition) internal view returns (uint256) {
        QueryCondition[] memory query = new QueryCondition[](2);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["StartPosition"]), abi.encode(_startPosition));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Resource"));
        uint256[] memory res = ECSLib.query(query);
        require(res.length <= 1, "CURIO: Resource assertion failed");
        return res.length == 1 ? res[0] : 0;
    }

    function getDelegations(
        string memory _functionName,
        uint256 _ownerID,
        uint256 _callerID
    ) internal view returns (uint256[] memory) {
        QueryCondition[] memory query = new QueryCondition[](4);
        query[0] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Tag"]), abi.encode("Delegation"));
        query[1] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["FunctionName"]), abi.encode(_functionName));
        query[2] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Owner"]), abi.encode(_ownerID));
        query[3] = ECSLib.queryChunk(QueryType.IsExactly, Component(gs().components["Caller"]), abi.encode(_callerID));
        return ECSLib.query(query);
    }

    function getNationCount() internal view returns (uint256) {
        return ECSLib.getStringComponent("Tag").getEntitiesWithValue(string("Nation")).length;
    }

    function generateNewAddress() internal returns (address) {
        address newAddress = address(uint160(uint256(keccak256(abi.encodePacked(gs().addressNonce, block.timestamp, block.difficulty)))));
        gs().addressNonce++;
        return newAddress;
    }

    function getTileNeighbors(Position memory _startPosition) internal view returns (Position[] memory) {
        require(isProperTilePosition(_startPosition), "CURIO: Intended for tile neighbor");

        Position[] memory temp = new Position[](4);
        uint256 x = _startPosition.x;
        uint256 y = _startPosition.y;
        uint256 tileWidth = gs().worldConstants.tileWidth;
        uint256 neighborCount = 0;

        if (x > 0) {
            temp[neighborCount] = (Position({x: x - tileWidth, y: y}));
            neighborCount++;
        }
        if (x < gs().worldConstants.worldWidth - tileWidth) {
            temp[neighborCount] = (Position({x: x + tileWidth, y: y}));
            neighborCount++;
        }
        if (y > 0) {
            temp[neighborCount] = (Position({x: x, y: y - tileWidth}));
            neighborCount++;
        }
        if (y < gs().worldConstants.worldHeight - tileWidth) {
            temp[neighborCount] = (Position({x: x, y: y + tileWidth}));
            neighborCount++;
        }

        Position[] memory result = new Position[](neighborCount);
        for (uint256 i = 0; i < neighborCount; i++) {
            result[i] = temp[i];
        }

        return result;
    }

    /// Fetch the 9-tile region around a given tile
    function getTileRegionTilePositions(Position memory _startPosition) internal view returns (Position[] memory) {
        require(isProperTilePosition(_startPosition), "CURIO: Intended for tile region");

        Position[] memory temp = new Position[](9);
        uint256 x;
        uint256 y;
        uint256 tileWidth = gs().worldConstants.tileWidth;
        uint256 neighborCount = 0;

        for (uint256 i; i < 3; i++) {
            x = _startPosition.x + i * tileWidth - tileWidth;
            if (x < 0 || x >= gs().worldConstants.worldWidth) continue;

            for (uint256 j; j < 3; j++) {
                y = _startPosition.y + j * tileWidth - tileWidth;
                if (y < 0 || y >= gs().worldConstants.worldHeight) continue;

                temp[neighborCount] = Position({x: x, y: y});
                neighborCount++;
            }
        }

        Position[] memory result = new Position[](neighborCount);
        for (uint256 i = 0; i < neighborCount; i++) {
            result[i] = temp[i];
        }

        return result;
    }

    function isAdjacentToOwnTile(uint256 _nationID, Position memory _tilePosition) internal view returns (bool) {
        Position[] memory neighborPositions = getTileNeighbors(_tilePosition);
        bool result = false;
        for (uint256 i = 0; i < neighborPositions.length; i++) {
            if (ECSLib.getUint("Nation", getTileAt(neighborPositions[i])) == _nationID) {
                result = true;
                break;
            }
        }
        return result;
    }

    function getNationTileCountByLevel(uint256 _level) internal pure returns (uint256) {
        require(_level >= 1, "CURIO: Nation level must be at least 1");
        return ((_level + 1) * (_level + 2)) / 2 + 6;
    }

    function getMapCenterTilePosition() internal view returns (Position memory) {
        uint256 tileWidth = gs().worldConstants.tileWidth;
        return Position({x: (gs().worldConstants.worldWidth / tileWidth / 2) * tileWidth, y: (gs().worldConstants.worldHeight / tileWidth / 2) * tileWidth});
    }

    // ----------------------------------------------------------
    // CHECKERS
    // ----------------------------------------------------------

    function ongoingGameCheck() internal view {
        uint256 gameLengthInSeconds = gs().worldConstants.gameLengthInSeconds;
        require(gameLengthInSeconds == 0 || (block.timestamp - gs().gameInitTimestamp) <= gameLengthInSeconds, "CURIO: Game has ended");
    }

    function validEntityCheck(uint256 _entity) internal view {
        require(Set(gs().entities).includes(_entity), "CURIO: Entity object not found");
    }

    function neutralOrOwnedTileCheck(uint256 _tileID, uint256 _nationID) internal view {
        uint256 tileNationID = ECSLib.getUint("Nation", _tileID);
        require(tileNationID == 0 || tileNationID == _nationID, "CURIO: Tile not neutral or owned");
    }

    function inboundPositionCheck(Position memory _position) internal view {
        require(inBound(_position), "CURIO: Position out of bound");
    }

    function passableTerrainCheck(Position memory _tilePosition) internal view {
        require(ECSLib.getUint("Terrain", getTileAt(_tilePosition)) != 5, "CURIO: Tile not passable");
    }

    function capitalSackRecoveryCheck(uint256 _capitalID) internal view {
        uint256 capitalLevel = ECSLib.getUint("Level", _capitalID);
        uint256 chaosDuration = getGameParameter("Capital", "", "Cooldown", "Chaos", capitalLevel);
        require(block.timestamp - ECSLib.getUint("LastSacked", _capitalID) > chaosDuration, "CURIO: Capital in chaos");
    }

    function validFunctionNameCheck(string memory _functionName) internal view {
        require(gs().isGameFunction[_functionName], "CURIO: Game function does not exist");
    }

    function nationDelegationCheck(
        string memory _functionName,
        uint256 _ownerID,
        uint256 _callerID,
        uint256 _subjectID
    ) internal view {
        uint256[] memory delegationIDs = getDelegations(_functionName, _ownerID, _callerID);
        for (uint256 i = 0; i < delegationIDs.length; i++) {
            uint256 subjectID = ECSLib.getUint("Subject", delegationIDs[i]);
            if (subjectID == 0 || subjectID == _subjectID) return;
        }
        revert(string.concat("CURIO: Not delegated to call ", _functionName));
    }

    function treatyApprovalCheck(
        string memory _functionName,
        uint256 _nationID,
        bytes memory _encodedParams
    ) internal {
        address[] memory treatyAddresses = getSignedTreatyAddresses(_nationID);
        for (uint256 i; i < treatyAddresses.length; i++) {
            (bool success, bytes memory data) = treatyAddresses[i].call(abi.encodeWithSignature(string.concat("approve", _functionName, "(uint256,bytes)"), _nationID, _encodedParams));
            require(success, string.concat("CURIO: Treaty approval check failed", string(data)));
            bool approved = abi.decode(data, (bool));
            require(approved, string.concat("CURIO: Treaty disapproved ", _functionName));
        }
    }

    // ----------------------------------------------------------
    // UTILITY FUNCTIONS
    // ----------------------------------------------------------

    function inBound(Position memory _p) internal view returns (bool) {
        return _p.x >= 0 && _p.x < gs().worldConstants.worldWidth && _p.y >= 0 && _p.y < gs().worldConstants.worldHeight;
    }

    function isBarbarian(uint256 _tileID) internal view returns (bool) {
        // FIXME: hardcoded
        return ECSLib.getUint("Terrain", _tileID) == 3 || ECSLib.getUint("Terrain", _tileID) == 4;
    }

    function random(uint256 _max, uint256 _salt) internal view returns (uint256) {
        return uint256(keccak256(abi.encode(block.timestamp, block.difficulty, _salt))) % _max;
    }

    function connected(Position[] memory _positions) internal view returns (bool) {
        require(_positions.length > 0, "CURIO: Positions cannot be empty");

        for (uint256 i = 1; i < _positions.length; i++) {
            if (!adjacent(_positions[i - 1], _positions[i])) return false;
        }

        return true;
    }

    /**
     * @dev Belong to adjacent tiles.
     */
    function adjacent(Position memory _p1, Position memory _p2) internal view returns (bool) {
        uint256 _xDist = _p1.x >= _p2.x ? _p1.x - _p2.x : _p2.x - _p1.x;
        uint256 _yDist = _p1.y >= _p2.y ? _p1.y - _p2.y : _p2.y - _p1.y;
        uint256 _tileWidth = gs().worldConstants.tileWidth;
        return (_xDist == 0 && _yDist == _tileWidth) || (_xDist == _tileWidth && _yDist == 0);
    }

    /**
     * @dev From any position, get its proper tile position.
     */
    function getProperTilePosition(Position memory _p) internal view returns (Position memory) {
        uint256 _tileWidth = gs().worldConstants.tileWidth;
        return Position({x: _p.x - (_p.x % _tileWidth), y: _p.y - (_p.y % _tileWidth)});
    }

    /**
     * @dev From any proper tile position, get the midpoint position of that tile. Often used for spawning units.
     */
    function getMidPositionFromTilePosition(Position memory _tilePosition) internal view returns (Position memory) {
        uint256 tileWidth = gs().worldConstants.tileWidth;
        return Position({x: _tilePosition.x + tileWidth / 2, y: _tilePosition.y + tileWidth / 2});
    }

    /**
     * @dev Determine whether a position is a proper tile position, aka located exactly at the top-left corner of a tile.
     */
    function isProperTilePosition(Position memory _p) internal view returns (bool) {
        uint256 tileWidth = gs().worldConstants.tileWidth;
        return _p.x % tileWidth == 0 && _p.y % tileWidth == 0;
    }

    function coincident(Position memory _p1, Position memory _p2) internal pure returns (bool) {
        return _p1.x == _p2.x && _p1.y == _p2.y;
    }

    // Note: The current version treats a diagonal movement as two movements.
    // For treating as one, use `xDist <= _dist && yDist <= _dist` as return condition.
    function withinDistance(
        Position memory _p1,
        Position memory _p2,
        uint256 _dist
    ) internal pure returns (bool) {
        uint256 xDist = _p1.x >= _p2.x ? _p1.x - _p2.x : _p2.x - _p1.x;
        uint256 yDist = _p1.y >= _p2.y ? _p1.y - _p2.y : _p2.y - _p1.y;
        return (xDist + yDist) <= _dist;
    }

    function strEq(string memory _s1, string memory _s2) internal pure returns (bool) {
        if (bytes(_s1).length != bytes(_s2).length) return false;
        return (keccak256(abi.encodePacked((_s1))) == keccak256(abi.encodePacked((_s2))));
    }

    function includes(uint256 _element, uint256[] memory _array) internal pure returns (bool) {
        uint256 index = find(_element, _array);
        return index < _array.length;
    }

    function find(uint256 _element, uint256[] memory _array) internal pure returns (uint256) {
        uint256 index = 0;
        while (index < _array.length) {
            if (_array[index] == _element) break;
            index++;
        }
        return index;
    }

    function euclidean(Position memory _p1, Position memory _p2) internal pure returns (uint256) {
        uint256 a = _p2.x >= _p1.x ? _p2.x - _p1.x : _p1.x - _p2.x;
        uint256 b = _p2.y >= _p1.y ? _p2.y - _p1.y : _p1.y - _p2.y;

        return sqrt(a**2 + b**2);
    }

    function sum(uint256[] memory _arr) internal pure returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < _arr.length; i++) {
            result += _arr[i];
        }
        return result;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? x : y;
    }
}
