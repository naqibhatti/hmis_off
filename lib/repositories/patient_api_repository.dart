import '../models/patient_data.dart';
import '../services/api_client.dart';
import 'patient_repository.dart';

class PatientApiRepository implements PatientRepository {
  final ApiClient api;
  PatientApiRepository(this.api);

  @override
  Future<PatientData> createPatient(PatientData p) async {
    final body = {
      'fullName': p.fullName,
      'cnic': p.cnic,
      'dateOfBirth': p.dateOfBirth.toIso8601String(),
      'gender': p.gender,
      'bloodGroup': p.bloodGroup,
      'email': p.email,
      'contactNumber': p.contactNumber,
      'address': p.address,
      'emergencyContact': p.emergencyContact ?? '',
      'emergencyContactRelation': p.emergencyContactRelation ?? '',
      'registrationType': 'Self',
      'parentType': null,
    };
    final json = await api.postJson('/api/patients', body);
    return p; // Map back if backend returns full entity; simplified for now
  }

  @override
  Future<PatientData?> getByCnic(String cnic) async {
    try {
      await api.getJson('/api/patients/by-cnic/$cnic');
      // Map response to PatientData as needed
      return null; // placeholder
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PatientData>> search({String? query, int page = 1, int pageSize = 20}) async {
    // Placeholder; wire when backend ready
    return [];
  }
}


