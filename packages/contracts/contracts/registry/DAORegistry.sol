// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {ENSSubdomainRegistrar} from "./ens/ENSSubdomainRegistrar.sol";
import {IDAO} from "../core/IDAO.sol";
import {InterfaceBasedRegistry} from "./InterfaceBasedRegistry.sol";
import {isSubdomainValid} from "./RegistryUtils.sol";

/// @title Register your unique DAO subdomain
/// @author Aragon Association - 2022
/// @notice This contract provides the possiblity to register a DAO.
contract DAORegistry is InterfaceBasedRegistry {
    /// @notice The ID of the permission required to call the `register` function.
    bytes32 public constant REGISTER_DAO_PERMISSION_ID = keccak256("REGISTER_DAO_PERMISSION");

    /// @notice The ENS subdomain registrar registering the DAO subdomains.
    ENSSubdomainRegistrar private subdomainRegistrar;

    /// @notice Thrown if the DAO subdomain doesn't match the regex `[0-9a-z\-]`
    error InvalidDaoSubdomain(string subdomain);

    /// @notice Emitted when a new DAO is registered.
    /// @param dao The address of the DAO contract.
    /// @param creator The address of the creator.
    /// @param subdomain The DAO subdomain.
    event DAORegistered(address indexed dao, address indexed creator, string subdomain);

    /// @dev Used to disallow initializing the implementation contract by an attacker for extra safety.
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the contract.
    /// @param _managingDao the managing DAO address.
    /// @param _subdomainRegistrar The `ENSSubdomainRegistrar` where `ENS` subdomain will be registered.
    function initialize(
        IDAO _managingDao,
        ENSSubdomainRegistrar _subdomainRegistrar
    ) public initializer {
        __InterfaceBasedRegistry_init(_managingDao, type(IDAO).interfaceId);
        subdomainRegistrar = _subdomainRegistrar;
    }

    /// @notice Registers a DAO by its address.
    /// @dev A subdomain is unique within the Aragon DAO framework and can get stored here.
    /// @param dao The address of the DAO contract.
    /// @param creator The address of the creator.
    /// @param subdomain The DAO subdomain.
    function register(
        IDAO dao,
        address creator,
        string calldata subdomain
    ) external auth(REGISTER_DAO_PERMISSION_ID) {
        address daoAddr = address(dao);

        _register(daoAddr);

        if ((bytes(subdomain).length > 0)) {
            if (!isSubdomainValid(subdomain)) {
                revert InvalidDaoSubdomain({subdomain: subdomain});
            }

            bytes32 labelhash = keccak256(bytes(subdomain));

            subdomainRegistrar.registerSubnode(labelhash, daoAddr);
        }

        emit DAORegistered(daoAddr, creator, subdomain);
    }

    /// @notice This empty reserved space is put in place to allow future versions to add new variables without shifting down storage in the inheritance chain (see [OpenZepplins guide about storage gaps](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)).
    uint256[49] private __gap;
}
