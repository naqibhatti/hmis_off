import '../models/patient_data.dart';

abstract class PatientRepository {
  Future<PatientData> createPatient(PatientData patient);
  Future<PatientData?> getByCnic(String cnic);
  Future<List<PatientData>> search({String? query, int page = 1, int pageSize = 20});
}

class MockPatientRepository implements PatientRepository {
  final List<PatientData> _store = [];

  @override
  Future<PatientData> createPatient(PatientData patient) async {
    _store.removeWhere((p) => p.cnic == patient.cnic);
    _store.add(patient);
    return patient;
  }

  @override
  Future<PatientData?> getByCnic(String cnic) async {
    try {
      return _store.firstWhere((p) => p.cnic == cnic);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PatientData>> search({String? query, int page = 1, int pageSize = 20}) async {
    Iterable<PatientData> q = _store;
    if (query != null && query.trim().isNotEmpty) {
      final lower = query.toLowerCase();
      q = q.where((p) =>
          p.fullName.toLowerCase().contains(lower) ||
          p.cnic.toLowerCase().contains(lower) ||
          p.phone.toLowerCase().contains(lower));
    }
    final start = (page - 1) * pageSize;
    return q.skip(start).take(pageSize).toList();
  }
}


