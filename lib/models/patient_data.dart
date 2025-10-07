import 'package:flutter/material.dart';

class PatientData {
  final int? patientID; // Backend ID
  final String? mrn; // Medical Record Number
  final String fullName;
  final int age; // Calculated from dateOfBirth
  final String bloodGroup;
  final String email;
  final String contactNumber; // Renamed from 'phone' to match backend
  final String address;
  final String cnic;
  final String gender;
  final DateTime dateOfBirth;
  final String? emergencyContact; // Renamed from 'emergencyContactName'
  final String? emergencyContactRelation; // Renamed from 'emergencyRelation'
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PatientData({
    this.patientID,
    this.mrn,
    required this.fullName,
    required this.age,
    required this.bloodGroup,
    required this.email,
    required this.contactNumber,
    required this.address,
    required this.cnic,
    required this.gender,
    required this.dateOfBirth,
    this.emergencyContact,
    this.emergencyContactRelation,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating from backend API response
  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      patientID: json['patientID'],
      mrn: json['mrn'],
      fullName: json['fullName'] ?? '',
      age: json['age'] ?? 0,
      bloodGroup: json['bloodGroup'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      cnic: json['cnic'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      emergencyContact: json['emergencyContact'],
      emergencyContactRelation: json['emergencyContactRelation'],
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (patientID != null) 'patientID': patientID,
      if (mrn != null) 'mrn': mrn,
      'fullName': fullName,
      'cnic': cnic,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyContactRelation': emergencyContactRelation,
      'bloodGroup': bloodGroup,
      'notes': notes,
      'isActive': isActive,
    };
  }

  // Convert to CreatePatientDto format for API
  Map<String, dynamic> toCreateDto() {
    return {
      'fullName': fullName,
      'cnic': _formatCnicForApi(cnic), // Remove dashes for API
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyContactRelation': emergencyContactRelation,
      'bloodGroup': bloodGroup,
      'notes': notes,
    };
  }

  // Helper method to format CNIC for API (remove dashes)
  String _formatCnicForApi(String cnic) {
    return cnic.replaceAll('-', '');
  }

  // Helper method to format CNIC for display (add dashes)
  String get formattedCnic {
    if (cnic.length == 13) {
      return '${cnic.substring(0, 5)}-${cnic.substring(5, 12)}-${cnic.substring(12)}';
    }
    return cnic;
  }

  // Legacy getter for backward compatibility
  String get phone => contactNumber;
  String? get emergencyContactName => emergencyContact;
  String? get emergencyRelation => emergencyContactRelation;
}

class PatientManager {
  static PatientData? _currentPatient;
  static List<VoidCallback> _listeners = [];

  static PatientData? get currentPatient => _currentPatient;

  static bool get hasPatient => _currentPatient != null;

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

  static void setPatient(PatientData patient) {
    _currentPatient = patient;
    _notifyListeners();
  }

  static void clearPatient() {
    _currentPatient = null;
    _notifyListeners();
  }
}
