import '../models/patient_data.dart';

class PatientDataService {
  // Comprehensive list of dummy patients for testing and demonstration
  // Includes various age groups, blood types, and medical conditions
  static final List<PatientData> _dummyPatients = [
    // Adult Patients
    PatientData(
      fullName: 'Ahmad Hassan',
      age: 45,
      bloodGroup: 'A+',
      email: 'ahmad.hassan@email.com',
      contactNumber: '0300-1234567',
      address: '123 Main Street, Lahore, Punjab',
      cnic: '12345-1234567-1',
      gender: 'Male',
      dateOfBirth: DateTime(1979, 3, 15),
    ),
    // Edge ages for pregnancy/FP logic
    PatientData(
      fullName: 'Young Teen Male',
      age: 13,
      bloodGroup: 'A+',
      email: 'teen.male13@email.com',
      contactNumber: '0301-1111113',
      address: 'Sector A, City',
      cnic: '13131-1313131-3',
      gender: 'Male',
      dateOfBirth: DateTime(DateTime.now().year - 13, 1, 1),
    ),
    PatientData(
      fullName: 'Teen Female Fourteen',
      age: 14,
      bloodGroup: 'B+',
      email: 'teen.female14@email.com',
      contactNumber: '0301-1111114',
      address: 'Sector B, City',
      cnic: '14141-1414141-4',
      gender: 'Female',
      dateOfBirth: DateTime(DateTime.now().year - 14, 2, 2),
    ),
    PatientData(
      fullName: 'Teen Female Fifteen',
      age: 15,
      bloodGroup: 'O+',
      email: 'teen.female15@email.com',
      contactNumber: '0301-1111115',
      address: 'Sector C, City',
      cnic: '15151-1515151-5',
      gender: 'Female',
      dateOfBirth: DateTime(DateTime.now().year - 15, 3, 3),
    ),
    PatientData(
      fullName: 'Fatima Ali',
      age: 38,
      bloodGroup: 'B+',
      email: 'fatima.ali@email.com',
      contactNumber: '0300-2345678',
      address: '456 Park Avenue, Karachi, Sindh',
      cnic: '23456-2345678-2',
      gender: 'Female',
      dateOfBirth: DateTime(1986, 7, 22),
    ),
    PatientData(
      fullName: 'Muhammad Usman',
      age: 52,
      bloodGroup: 'O+',
      email: 'm.usman@email.com',
      contactNumber: '0300-3456789',
      address: '789 Garden Road, Islamabad, Capital',
      cnic: '34567-3456789-3',
      gender: 'Male',
      dateOfBirth: DateTime(1972, 11, 8),
    ),
    PatientData(
      fullName: 'Ayesha Khan',
      age: 29,
      bloodGroup: 'AB+',
      email: 'ayesha.khan@email.com',
      contactNumber: '0300-4567890',
      address: '321 University Road, Peshawar, KPK',
      cnic: '45678-4567890-4',
      gender: 'Female',
      dateOfBirth: DateTime(1995, 5, 12),
    ),
    PatientData(
      fullName: 'Hassan Raza',
      age: 41,
      bloodGroup: 'A-',
      email: 'hassan.raza@email.com',
      contactNumber: '0300-5678901',
      address: '654 Mall Road, Rawalpindi, Punjab',
      cnic: '56789-5678901-5',
      gender: 'Male',
      dateOfBirth: DateTime(1983, 9, 30),
    ),
    PatientData(
      fullName: 'Sara Ahmed',
      age: 35,
      bloodGroup: 'B-',
      email: 'sara.ahmed@email.com',
      contactNumber: '0300-6789012',
      address: '987 Cantonment Area, Quetta, Balochistan',
      cnic: '67890-6789012-6',
      gender: 'Female',
      dateOfBirth: DateTime(1989, 1, 18),
    ),
    PatientData(
      fullName: 'Ali Rizwan',
      age: 48,
      bloodGroup: 'O-',
      email: 'ali.rizwan@email.com',
      contactNumber: '0300-7890123',
      address: '147 Model Town, Faisalabad, Punjab',
      cnic: '78901-7890123-7',
      gender: 'Male',
      dateOfBirth: DateTime(1976, 12, 3),
    ),
    PatientData(
      fullName: 'Zainab Malik',
      age: 33,
      bloodGroup: 'AB-',
      email: 'zainab.malik@email.com',
      contactNumber: '0300-8901234',
      address: '258 Defense Housing, Lahore, Punjab',
      cnic: '89012-8901234-8',
      gender: 'Female',
      dateOfBirth: DateTime(1991, 4, 25),
    ),
    PatientData(
      fullName: 'Omar Sheikh',
      age: 56,
      bloodGroup: 'A+',
      email: 'omar.sheikh@email.com',
      contactNumber: '0300-9012345',
      address: '369 Gulberg, Lahore, Punjab',
      cnic: '90123-9012345-9',
      gender: 'Male',
      dateOfBirth: DateTime(1968, 8, 14),
    ),
    PatientData(
      fullName: 'Nadia Hussain',
      age: 42,
      bloodGroup: 'B+',
      email: 'nadia.hussain@email.com',
      contactNumber: '0300-0123456',
      address: '741 Clifton, Karachi, Sindh',
      cnic: '01234-0123456-0',
      gender: 'Female',
      dateOfBirth: DateTime(1982, 6, 7),
    ),
    
    // Elderly Patients
    PatientData(
      fullName: 'Abdul Rahman',
      age: 72,
      bloodGroup: 'O+',
      email: 'abdul.rahman@email.com',
      contactNumber: '0300-1111111',
      address: '852 Old City, Multan, Punjab',
      cnic: '11111-1111111-1',
      gender: 'Male',
      dateOfBirth: DateTime(1952, 2, 20),
    ),
    PatientData(
      fullName: 'Bibi Khadija',
      age: 68,
      bloodGroup: 'A+',
      email: 'bibi.khadija@email.com',
      contactNumber: '0300-2222222',
      address: '963 Saddar, Rawalpindi, Punjab',
      cnic: '22222-2222222-2',
      gender: 'Female',
      dateOfBirth: DateTime(1956, 10, 11),
    ),
    
    // Young Adult Patients
    PatientData(
      fullName: 'Hassan Ali',
      age: 22,
      bloodGroup: 'B+',
      email: 'hassan.ali@email.com',
      contactNumber: '0300-3333333',
      address: '159 University Town, Lahore, Punjab',
      cnic: '33333-3333333-3',
      gender: 'Male',
      dateOfBirth: DateTime(2002, 3, 28),
    ),
    PatientData(
      fullName: 'Amina Shah',
      age: 26,
      bloodGroup: 'AB+',
      email: 'amina.shah@email.com',
      contactNumber: '0300-4444444',
      address: '357 DHA Phase 2, Karachi, Sindh',
      cnic: '44444-4444444-4',
      gender: 'Female',
      dateOfBirth: DateTime(1998, 9, 15),
    ),
    
    // Pediatric Patients (with guardian info)
    PatientData(
      fullName: 'Ahmad Junior',
      age: 8,
      bloodGroup: 'A+',
      email: 'ahmad.junior@email.com',
      contactNumber: '0300-5555555',
      address: '753 Model Colony, Lahore, Punjab',
      cnic: '55555-5555555-5',
      gender: 'Male',
      dateOfBirth: DateTime(2016, 1, 10),
    ),
    PatientData(
      fullName: 'Fatima Junior',
      age: 12,
      bloodGroup: 'B+',
      email: 'fatima.junior@email.com',
      contactNumber: '0300-6666666',
      address: '951 Johar Town, Lahore, Punjab',
      cnic: '66666-6666666-6',
      gender: 'Female',
      dateOfBirth: DateTime(2012, 11, 5),
    ),
    
    // Patients with specific conditions (for testing vitals)
    PatientData(
      fullName: 'Muhammad Diabetic',
      age: 55,
      bloodGroup: 'A+',
      email: 'm.diabetic@email.com',
      contactNumber: '0300-7777777',
      address: '147 Medical District, Lahore, Punjab',
      cnic: '77777-7777777-7',
      gender: 'Male',
      dateOfBirth: DateTime(1969, 4, 18),
    ),
    PatientData(
      fullName: 'Ayesha Hypertensive',
      age: 47,
      bloodGroup: 'B+',
      email: 'ayesha.hypertensive@email.com',
      contactNumber: '0300-8888888',
      address: '258 Cardiac Center, Karachi, Sindh',
      cnic: '88888-8888888-8',
      gender: 'Female',
      dateOfBirth: DateTime(1977, 8, 22),
    ),
    PatientData(
      fullName: 'Hassan Obese',
      age: 39,
      bloodGroup: 'O+',
      email: 'hassan.obese@email.com',
      contactNumber: '0300-9999999',
      address: '369 Fitness Zone, Islamabad, Capital',
      cnic: '99999-9999999-9',
      gender: 'Male',
      dateOfBirth: DateTime(1985, 12, 30),
    ),
    PatientData(
      fullName: 'Sara Underweight',
      age: 31,
      bloodGroup: 'AB-',
      email: 'sara.underweight@email.com',
      contactNumber: '0300-0000000',
      address: '741 Nutrition Center, Peshawar, KPK',
      cnic: '00000-0000000-0',
      gender: 'Female',
      dateOfBirth: DateTime(1993, 6, 14),
    ),
  ];

  // Get all dummy patients
  static List<PatientData> get allPatients => List.unmodifiable(_dummyPatients);

  // Get patients by age group
  static List<PatientData> getPatientsByAgeGroup(String ageGroup) {
    switch (ageGroup.toLowerCase()) {
      case 'pediatric':
        return _dummyPatients.where((p) => p.age < 18).toList();
      case 'adult':
        return _dummyPatients.where((p) => p.age >= 18 && p.age < 65).toList();
      case 'elderly':
        return _dummyPatients.where((p) => p.age >= 65).toList();
      default:
        return _dummyPatients;
    }
  }

  // Get patients by blood group
  static List<PatientData> getPatientsByBloodGroup(String bloodGroup) {
    return _dummyPatients.where((p) => p.bloodGroup == bloodGroup).toList();
  }

  // Search patients by name or CNIC
  static List<PatientData> searchPatients(String query) {
    if (query.isEmpty) return _dummyPatients;
    
    final lowerQuery = query.toLowerCase();
    return _dummyPatients.where((patient) {
      final matchesName = patient.fullName.toLowerCase().contains(lowerQuery);
      final matchesCNIC = patient.cnic.contains(query);
      final matchesPhone = patient.contactNumber.contains(query);
      final matchesGender = patient.gender.toLowerCase().startsWith(lowerQuery);
      final matchesAge = int.tryParse(lowerQuery) != null && patient.age == int.parse(lowerQuery);
      return matchesName || matchesCNIC || matchesPhone || matchesGender || matchesAge;
    }).toList();
  }

  // Get patient by CNIC
  static PatientData? getPatientByCNIC(String cnic) {
    try {
      return _dummyPatients.firstWhere((patient) => patient.cnic == cnic);
    } catch (e) {
      return null;
    }
  }

  // Add new patient to the list
  static void addPatient(PatientData patient) {
    _dummyPatients.add(patient);
  }

  // Get patient count
  static int get patientCount => _dummyPatients.length;

  // Get patients with specific conditions (for testing)
  static List<PatientData> getPatientsWithConditions() {
    return _dummyPatients.where((p) => 
      p.fullName.toLowerCase().contains('diabetic') ||
      p.fullName.toLowerCase().contains('hypertensive') ||
      p.fullName.toLowerCase().contains('obese') ||
      p.fullName.toLowerCase().contains('underweight')
    ).toList();
  }
}
