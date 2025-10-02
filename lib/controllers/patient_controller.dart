import '../models/patient_data.dart';
import '../repositories/patient_repository.dart';

class PatientController {
  final PatientRepository repository;

  PatientController({required this.repository});

  Future<PatientData> register(PatientData patient) async {
    final existing = await repository.getByCnic(patient.cnic);
    if (existing != null) {
      return existing; // or throw
    }
    final created = await repository.createPatient(patient);
    PatientManager.setPatient(created);
    return created;
  }

  Future<PatientData?> findByCnic(String cnic) => repository.getByCnic(cnic);
}


