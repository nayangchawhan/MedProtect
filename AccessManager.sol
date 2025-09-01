// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./RecordRegistry.sol";
import "./PatientRegistry.sol";

contract AccessManager {
    struct Grant {
        uint64 expiry;
        bytes encFileKey; // Encrypted symmetric key
    }

    mapping(uint256 => mapping(address => Grant)) public grants;

    RecordRegistry public recordRegistry;
    PatientRegistry public patientRegistry;

    event AccessGranted(uint256 indexed recordId, address indexed doctor, uint64 expiry);
    event AccessRevoked(uint256 indexed recordId, address indexed doctor);

    constructor(address _recordRegistry, address _patientRegistry) {
        recordRegistry = RecordRegistry(_recordRegistry);
        patientRegistry = PatientRegistry(_patientRegistry);
    }

    function grantAccess(
        uint256 recordId,
        address doctor,
        uint64 expiry,
        bytes calldata encFileKey
    ) external {
        (, , , address owner, ) = recordRegistry.getRecord(recordId);
        require(owner == msg.sender, "Not record owner");
        require(patientRegistry.isDoctor(doctor), "Not a doctor");

        grants[recordId][doctor] = Grant(expiry, encFileKey);

        emit AccessGranted(recordId, doctor, expiry);
    }

    function revokeAccess(uint256 recordId, address doctor) external {
        (, , , address owner, ) = recordRegistry.getRecord(recordId);
        require(owner == msg.sender, "Not record owner");

        delete grants[recordId][doctor];
        emit AccessRevoked(recordId, doctor);
    }

    function hasAccess(uint256 recordId, address doctor) external view returns (bool) {
        Grant memory g = grants[recordId][doctor];
        return g.expiry != 0 && g.expiry >= block.timestamp;
    }

    function getEncKey(uint256 recordId, address doctor) external view returns (bytes memory) {
        Grant memory g = grants[recordId][doctor];
        require(g.expiry >= block.timestamp, "Access expired or not granted");
        return g.encFileKey;
    }
}
