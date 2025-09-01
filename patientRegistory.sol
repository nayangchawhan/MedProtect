// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract PatientRegistry {
    mapping(address => bool) private patients;
    mapping(address => bool) private doctors;

    event PatientRegistered(address indexed patient);
    event DoctorRegistered(address indexed doctor);

    function registerPatient() external {
        patients[msg.sender] = true;
        emit PatientRegistered(msg.sender);
    }

    function registerDoctor() external {
        doctors[msg.sender] = true;
        emit DoctorRegistered(msg.sender);
    }

    function isPatient(address user) external view returns (bool) {
        return patients[user];
    }

    function isDoctor(address user) external view returns (bool) {
        return doctors[user];
    }
}
