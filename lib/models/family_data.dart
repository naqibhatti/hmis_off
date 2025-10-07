import 'package:flutter/material.dart';
import 'patient_data.dart';

class FamilyMember {
  final int? id;
  final String fullName;
  final int age;
  final String bloodGroup;
  final String email;
  final String phone;
  final String address;
  final String cnic;
  final String gender;
  final DateTime dateOfBirth;
  final String relationship; // e.g., "Father", "Mother", "Son", "Daughter", "Spouse"
  final DateTime? createdAt;

  FamilyMember({
    this.id,
    required this.fullName,
    required this.age,
    required this.bloodGroup,
    required this.email,
    required this.phone,
    required this.address,
    required this.cnic,
    required this.gender,
    required this.dateOfBirth,
    required this.relationship,
    this.createdAt,
  });

  // Convert from PatientData
  factory FamilyMember.fromPatientData(PatientData patient, String relationship) {
    return FamilyMember(
      id: null, // Will be set when saved to database
      fullName: patient.fullName,
      age: patient.age,
      bloodGroup: patient.bloodGroup,
      email: patient.email,
      phone: patient.contactNumber, // Updated to use contactNumber
      address: patient.address,
      cnic: patient.cnic,
      gender: patient.gender,
      dateOfBirth: patient.dateOfBirth,
      relationship: relationship,
    );
  }

  // Convert to PatientData
  PatientData toPatientData() {
    return PatientData(
      fullName: fullName,
      age: age,
      bloodGroup: bloodGroup,
      email: email,
      contactNumber: phone, // Updated to use contactNumber
      address: address,
      cnic: cnic,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }

  // Get last name from full name
  String get lastName {
    final nameParts = fullName.trim().split(' ');
    return nameParts.isNotEmpty ? nameParts.last : '';
  }
}

class Family {
  final int? id;
  final FamilyMember headOfFamily;
  final List<FamilyMember> members;
  final DateTime? createdAt;

  Family({
    this.id,
    required this.headOfFamily,
    required this.members,
    this.createdAt,
  });

  // Get family name (head's last name + "Family")
  String get familyName {
    final lastName = headOfFamily.lastName;
    return lastName.isNotEmpty ? '$lastName Family' : 'Unknown Family';
  }

  // Get all family members including head
  List<FamilyMember> get allMembers {
    return [headOfFamily, ...members];
  }

  // Add a new family member
  Family addMember(FamilyMember newMember) {
    return Family(
      id: id,
      headOfFamily: headOfFamily,
      members: [...members, newMember],
      createdAt: createdAt,
    );
  }

  // Remove a family member
  Family removeMember(FamilyMember memberToRemove) {
    return Family(
      id: id,
      headOfFamily: headOfFamily,
      members: members.where((member) => member.cnic != memberToRemove.cnic).toList(),
      createdAt: createdAt,
    );
  }
}

class FamilyManager {
  static List<Family> _families = [];
  static List<VoidCallback> _listeners = [];

  static List<Family> get families => List.unmodifiable(_families);

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Add a new family
  static void addFamily(Family family) {
    _families.add(family);
    _notifyListeners();
  }

  // Update an existing family
  static void updateFamily(int index, Family updatedFamily) {
    if (index >= 0 && index < _families.length) {
      _families[index] = updatedFamily;
      _notifyListeners();
    }
  }

  // Delete a family
  static void deleteFamily(int index) {
    if (index >= 0 && index < _families.length) {
      _families.removeAt(index);
      _notifyListeners();
    }
  }

  // Find family by head's CNIC
  static Family? findFamilyByHeadCNIC(String cnic) {
    try {
      return _families.firstWhere((family) => family.headOfFamily.cnic == cnic);
    } catch (e) {
      return null;
    }
  }

  // Get all heads of family
  static List<FamilyMember> get allHeadsOfFamily {
    return _families.map((family) => family.headOfFamily).toList();
  }

  // Change head of family
  static bool changeHeadOfFamily(int familyIndex, FamilyMember newHead) {
    if (familyIndex >= 0 && familyIndex < _families.length) {
      final family = _families[familyIndex];
      
      // Check if the new head is already a member of the family
      final existingMemberIndex = family.members.indexWhere(
        (member) => member.cnic == newHead.cnic
      );
      
      Family updatedFamily;
      
      if (existingMemberIndex != -1) {
        // New head is already a family member
        final oldHead = family.headOfFamily;
        final newHeadMember = family.members[existingMemberIndex];
        
        // Create updated members list
        final updatedMembers = List<FamilyMember>.from(family.members);
        updatedMembers.removeAt(existingMemberIndex);
        updatedMembers.add(FamilyMember(
          fullName: oldHead.fullName,
          age: oldHead.age,
          bloodGroup: oldHead.bloodGroup,
          email: oldHead.email,
          phone: oldHead.phone,
          address: oldHead.address,
          cnic: oldHead.cnic,
          gender: oldHead.gender,
          dateOfBirth: oldHead.dateOfBirth,
          relationship: 'Family Member', // Default relationship
        ));
        
        // Create new family with updated head and members
        updatedFamily = Family(
          id: family.id,
          headOfFamily: newHeadMember,
          members: updatedMembers,
          createdAt: family.createdAt,
        );
      } else {
        // New head is not a family member, add them and make them head
        final oldHead = family.headOfFamily;
        final updatedMembers = List<FamilyMember>.from(family.members);
        updatedMembers.add(FamilyMember(
          fullName: oldHead.fullName,
          age: oldHead.age,
          bloodGroup: oldHead.bloodGroup,
          email: oldHead.email,
          phone: oldHead.phone,
          address: oldHead.address,
          cnic: oldHead.cnic,
          gender: oldHead.gender,
          dateOfBirth: oldHead.dateOfBirth,
          relationship: 'Family Member', // Default relationship
        ));
        
        // Create new family with new head and updated members
        updatedFamily = Family(
          id: family.id,
          headOfFamily: newHead,
          members: updatedMembers,
          createdAt: family.createdAt,
        );
      }
      
      // Replace the family in the list
      _families[familyIndex] = updatedFamily;
      _notifyListeners();
      return true;
    }
    return false;
  }

  // Clear all families (for testing)
  static void clearAllFamilies() {
    _families.clear();
    _notifyListeners();
  }
}
