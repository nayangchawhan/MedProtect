// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PatientRegistry.sol";

contract RecordRegistry {
    struct Record {
        address owner;
        string ipfsCid;
        string fileHash; // Changed from bytes32 to string
        uint64 createdAt;
    }

    uint256 public nextId;
    mapping(uint256 => Record) public records;

    PatientRegistry public patientRegistry;

    event RecordAdded(uint256 indexed id, address indexed owner, string ipfsCid, string fileHash);

    constructor(address _patientRegistry) {
        patientRegistry = PatientRegistry(_patientRegistry);
    }

    // Add new record
    function addRecord(string calldata ipfsCid, string calldata fileHash) external returns (uint256 id) {
        require(patientRegistry.isPatient(msg.sender), "Not registered patient");

        id = ++nextId;
        records[id] = Record(msg.sender, ipfsCid, fileHash, uint64(block.timestamp));

        emit RecordAdded(id, msg.sender, ipfsCid, fileHash);
    }

    // Fetch record by ID
    function getRecord(uint256 recordId) external view returns (
        uint256 id,
        string memory ipfsCid,
        string memory fileHash,
        address owner,
        uint64 createdAt
    ) {
        Record storage rec = records[recordId];
        return (recordId, rec.ipfsCid, rec.fileHash, rec.owner, rec.createdAt);
    }

    // Get total records
    function getTotalRecords() external view returns (uint256) {
        return nextId;
    }
}
