import 'package:flutter/material.dart';
import '../models/patient_data.dart';

class VitalsRecord {
  final String id;
  final String patientCnic;
  final int systolic;
  final int diastolic;
  final double weight;
  final double? temperature;
  final int? pulse;
  final double height;
  final DateTime recordedAt;
  final String recordedBy; // Doctor or Receptionist

  VitalsRecord({
    required this.id,
    required this.patientCnic,
    required this.systolic,
    required this.diastolic,
    required this.weight,
    this.temperature,
    this.pulse,
    required this.height,
    required this.recordedAt,
    required this.recordedBy,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientCnic': patientCnic,
      'systolic': systolic,
      'diastolic': diastolic,
      'weight': weight,
      'temperature': temperature,
      'pulse': pulse,
      'height': height,
      'recordedAt': recordedAt.toIso8601String(),
      'recordedBy': recordedBy,
    };
  }

  // Create from Map
  factory VitalsRecord.fromMap(Map<String, dynamic> map) {
    return VitalsRecord(
      id: map['id'],
      patientCnic: map['patientCnic'],
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      weight: map['weight'],
      temperature: map['temperature'],
      pulse: map['pulse'],
      height: map['height'],
      recordedAt: DateTime.parse(map['recordedAt']),
      recordedBy: map['recordedBy'],
    );
  }
}

class VitalsStorageService {
  static final List<VitalsRecord> _vitalsRecords = [];
  static final List<VoidCallback> _listeners = [];

  // Add a new vitals record
  static void addVitalsRecord(VitalsRecord record) {
    _vitalsRecords.add(record);
    _notifyListeners();
  }

  // Get all vitals for a specific patient
  static List<VitalsRecord> getPatientVitals(String patientCnic) {
    return _vitalsRecords
        .where((record) => record.patientCnic == patientCnic)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)); // Most recent first
  }

  // Get the most recent vitals for a patient
  static VitalsRecord? getLatestVitals(String patientCnic) {
    final patientVitals = getPatientVitals(patientCnic);
    return patientVitals.isNotEmpty ? patientVitals.first : null;
  }

  // Get vitals count for a patient
  static int getVitalsCount(String patientCnic) {
    return _vitalsRecords.where((record) => record.patientCnic == patientCnic).length;
  }

  // Get all vitals records
  static List<VitalsRecord> getAllVitals() {
    return List.unmodifiable(_vitalsRecords);
  }

  // Delete a vitals record
  static void deleteVitalsRecord(String recordId) {
    _vitalsRecords.removeWhere((record) => record.id == recordId);
    _notifyListeners();
  }

  // Clear all vitals (for testing)
  static void clearAllVitals() {
    _vitalsRecords.clear();
    _notifyListeners();
  }

  // Add listener for updates
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remove listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Get vitals statistics for a patient
  static Map<String, dynamic> getVitalsStatistics(String patientCnic) {
    final patientVitals = getPatientVitals(patientCnic);
    if (patientVitals.isEmpty) {
      return {
        'totalRecords': 0,
        'averageSystolic': 0.0,
        'averageDiastolic': 0.0,
        'averageWeight': 0.0,
        'averageTemperature': 0.0,
        'averagePulse': 0.0,
        'averageHeight': 0.0,
        'lastRecorded': null,
      };
    }

    final systolicValues = patientVitals.map((v) => v.systolic).toList();
    final diastolicValues = patientVitals.map((v) => v.diastolic).toList();
    final weightValues = patientVitals.map((v) => v.weight).toList();
    final temperatureValues = patientVitals.where((v) => v.temperature != null).map((v) => v.temperature!).toList();
    final pulseValues = patientVitals.where((v) => v.pulse != null).map((v) => v.pulse!).toList();
    final heightValues = patientVitals.map((v) => v.height).toList();

    return {
      'totalRecords': patientVitals.length,
      'averageSystolic': systolicValues.reduce((a, b) => a + b) / systolicValues.length,
      'averageDiastolic': diastolicValues.reduce((a, b) => a + b) / diastolicValues.length,
      'averageWeight': weightValues.reduce((a, b) => a + b) / weightValues.length,
      'averageTemperature': temperatureValues.isNotEmpty 
          ? temperatureValues.reduce((a, b) => a + b) / temperatureValues.length 
          : 0.0,
      'averagePulse': pulseValues.isNotEmpty 
          ? pulseValues.reduce((a, b) => a + b) / pulseValues.length 
          : 0.0,
      'averageHeight': heightValues.reduce((a, b) => a + b) / heightValues.length,
      'lastRecorded': patientVitals.first.recordedAt,
    };
  }
}
