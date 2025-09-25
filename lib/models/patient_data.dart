import 'package:flutter/material.dart';

class PatientData {
  final String fullName;
  final int age;
  final String bloodGroup;
  final String email;
  final String phone;
  final String address;
  final String cnic;
  final String gender;
  final DateTime dateOfBirth;

  PatientData({
    required this.fullName,
    required this.age,
    required this.bloodGroup,
    required this.email,
    required this.phone,
    required this.address,
    required this.cnic,
    required this.gender,
    required this.dateOfBirth,
  });
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
