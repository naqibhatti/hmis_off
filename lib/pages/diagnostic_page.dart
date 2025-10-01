import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/patient_data_service.dart';
import '../services/vitals_storage_service.dart';
import '../services/diseases_service.dart';
import '../models/patient_data.dart';
import '../theme/shadcn_colors.dart';
import '../theme/theme_controller.dart';
import '../widgets/side_navigation_drawer.dart';

class DiagnosticPage extends StatefulWidget {
  final String? patientName;
  final int? patientAge;
  final String? patientBloodGroup;

  const DiagnosticPage({
    super.key,
    this.patientName,
    this.patientAge,
    this.patientBloodGroup,
  });

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Patient Selection
  PatientData? _selectedPatient;
  List<PatientData> _allPatients = [];
  List<VitalsRecord> _patientVitals = [];
  
  // Diagnosis Controllers
  final _diseaseController = TextEditingController();
  late TextEditingController _diseaseSearchController;
  final _followupDateController = TextEditingController();
  final _doctorNotesController = TextEditingController();
  
  // Disease search
  List<Disease> _allDiseases = [];
  List<Disease> _filteredDiseases = [];
  Disease? _selectedDisease;
  
  // Lab reports modal state
  String _searchQuery = '';
  String _selectedTestType = 'individual';
  int _labListVisibleCount = 5;
  final Set<String> _selectedLabTests = <String>{};
  
  // Lab tests data
  static const List<String> _packageTests = [
    'Basic Metabolic Panel',
    'Comprehensive Metabolic Panel',
    'Lipid Profile',
    'Liver Function Tests',
    'Thyroid Function Profile',
    'Cardiac Panel',
    'Coagulation Panel',
    'Anemia Workup',
    'Diabetes Panel',
    'Hepatitis Panel',
    'STI Screening Panel',
    'Tumor Markers (Male)',
    'Tumor Markers (Female)',
    '5-Panel Drug Screen',
    'Pre-operative Panel',
    'Prenatal Panel',
  ];
  
  static const List<String> _individualTests = [
    'Glucose',
    'Urea/BUN',
    'Creatinine',
    'Sodium',
    'Potassium',
    'Chloride',
    'Carbon Dioxide',
    'Alanine Aminotransferase (ALT)',
    'Aspartate Aminotransferase (AST)',
    'Alkaline Phosphatase',
    'Total Bilirubin',
    'Direct Bilirubin',
    'Albumin',
    'Total Protein',
    'Total Cholesterol',
    'Triglycerides',
    'HDL Cholesterol',
    'LDL Cholesterol',
    'Troponin I',
    'Troponin T',
    'CK-MB',
    'NT-proBNP',
    'B-Type Natriuretic Peptide',
    'Creatine Kinase Total',
    'Neutrophils %',
    'Lymphocytes %',
    'Monocytes %',
    'Eosinophils %',
    'Basophils %',
    'Prothrombin Time',
    'International Normalized Ratio',
    'Partial Thromboplastin Time',
    'D-Dimer',
    'Fibrinogen',
    'Hemoglobin',
    'Hematocrit',
    'Mean Cell Volume',
    'Mean Cell Hemoglobin',
    'Mean Cell Hemoglobin Concentration',
    'Platelet Count',
    'Red Cell Distribution Width',
    'White Blood Cell Count',
    'Red Blood Cell Count',
    'Thyroid Stimulating Hormone',
    'Thyroxine (T4)',
    'Triiodothyronine (T3)',
    'Free Thyroxine',
    'Free Triiodothyronine',
    'Luteinizing Hormone',
    'Follicle Stimulating Hormone',
    'Prolactin',
    'Testosterone',
    'Estradiol',
    'Updated Test',
    'Insulin',
    'Hemoglobin A1c',
    'VDRL/RPR',
    'Treponema pallidum Antibody',
    'Prostate Specific Antigen',
    'Carcinoembryonic Antigen',
    'Alpha Fetoprotein',
    'Cancer Antigen 125',
    'Cancer Antigen 19-9',
    'Hepatitis B Surface Antigen',
    'Hepatitis B Surface Antibody',
    'Hepatitis C Antibody',
    'Blood Culture Aerobic',
    'Blood Culture Anaerobic',
    'Urine Culture',
    'Sputum Culture',
    'Throat Culture',
    'Wound Culture',
    'Stool Culture',
    'Stool Ova and Parasites',
    'Gram Stain',
    'Pap Smear (Conventional)',
    'Liquid Based Cytology',
    'Fine Needle Aspiration Cytology',
    'Body Fluid Cytology',
    'Routine Histopathology',
    'Frozen Section',
    'Immunohistochemistry (Single Stain)',
    'Special Stains',
    'Drug Screen (Urine)',
    'Cocaine (Urine)',
    'Cannabis (THC) Urine',
    'Amphetamines (Urine)',
    'Digoxin Level',
    'Phenytoin Level',
    'Lithium Level',
    'Blood Alcohol Level',
  ];
  
  // Prescription Controllers
  final _medicineNameController = TextEditingController();
  final _medicineInstructionsController = TextEditingController();
  
  // Medicine dropdown
  String? _selectedMedicine;
  
  // Available medicines
  static const List<String> _availableMedicines = [
    'Panadol 500mg Tablet',
    'Paracetamol 500mg Tablet',
    'Panadol Syrup 120mg/5ml',
    'Brufen 400mg Tablet',
    'Ibuprofen 400mg Tablet',
    'Brufen Suspension 100mg/5ml',
    'Amoxil 500mg Capsule',
    'Amoxicillin 500mg Capsule',
    'Amoxil 125mg/5ml Suspension',
    'Glucophage 500mg Tablet',
    'Metformin 500mg Tablet',
    'Norvasc 5mg Tablet',
    'Amlodipine 5mg Tablet',
    'Losec 20mg Capsule',
    'Ventolin Inhaler 100mcg',
    'Claritin 10mg Tablet',
    'Zocor 20mg Tablet',
    'Keflex 500mg Capsule',
    'Panadol 100mg Tablet',
  ];
  
  List<Map<String, String>> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _diseaseSearchController = TextEditingController();
    _loadPatients();
    _loadDiseases();
    _diseaseSearchController.addListener(_filterDiseases);
  }

  @override
  void dispose() {
    _diseaseController.dispose();
    _diseaseSearchController.dispose();
    _followupDateController.dispose();
    _doctorNotesController.dispose();
    _medicineNameController.dispose();
    _medicineInstructionsController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    setState(() {
      _allPatients = PatientDataService.allPatients;
      if (widget.patientName != null) {
        _selectedPatient = _allPatients.firstWhere(
          (patient) => patient.fullName == widget.patientName,
          orElse: () => _allPatients.first,
        );
        _loadPatientVitals();
      }
    });
  }

  void _loadDiseases() {
    setState(() {
      _allDiseases = DiseasesService.getAllDiseases();
      _filteredDiseases = _allDiseases;
    });
  }

  void _filterDiseases() {
    setState(() {
      _filteredDiseases = DiseasesService.searchDiseases(_diseaseSearchController.text);
    });
  }

  IconData _getDiseaseIcon(String category) {
    switch (category) {
      case 'Cardiovascular':
        return Icons.favorite;
      case 'Respiratory':
        return Icons.air;
      case 'Endocrine':
        return Icons.biotech;
      case 'Gastrointestinal':
        return Icons.restaurant;
      case 'Neurological':
        return Icons.psychology;
      case 'Musculoskeletal':
        return Icons.accessibility;
      case 'Infectious':
        return Icons.bug_report;
      case 'Mental Health':
        return Icons.psychology;
      case 'Dermatological':
        return Icons.face;
      case 'Urological':
        return Icons.water_drop;
      case 'Gynecological':
        return Icons.pregnant_woman;
      case 'Pediatric':
        return Icons.child_care;
      default:
        return Icons.medical_services;
    }
  }

  void _loadPatientVitals() {
    if (_selectedPatient != null) {
      setState(() {
        _patientVitals = VitalsStorageService.getPatientVitals(_selectedPatient!.cnic);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SideNavigationDrawer(
        currentRoute: '/diagnostic',
        userType: 'Doctor',
        child: Column(
          children: <Widget>[
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 16),
                        // Patient Selection and Vitals Display Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.blue.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Patient Information & Vitals',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Selected Patient section (mirrors Collect Vitals page)
                              Builder(
                                builder: (_) {
                                  final p = _selectedPatient ?? PatientManager.currentPatient;
                                  if (p == null) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange.shade200),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.orange.shade700,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 16),
                                          const Expanded(
                                            child: Text(
                                              'No patient selected. Vitals will be recorded without patient information.',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ShadcnColors.accent50,
                                      border: Border.all(color: ShadcnColors.accent200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: ShadcnColors.accent100,
                                          child: Text(
                                            p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                                            style: TextStyle(
                                              color: ShadcnColors.accent700,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Patient: ${p.fullName}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: ShadcnColors.accent700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Age: ${p.age} years • ${p.gender}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: ShadcnColors.accent600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Blood Group: ${p.bloodGroup} • CNIC: ${p.cnic}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: ShadcnColors.accent600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Phone: ${p.phone}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: ShadcnColors.accent600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (_selectedPatient != null) ...[
                                const SizedBox(height: 20),
                                // Patient Info Card (styled similar to Collect Vitals)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: ShadcnColors.accent50,
                                    border: Border.all(color: ShadcnColors.accent200),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: ShadcnColors.accent100,
                                        child: Text(
                                          _selectedPatient!.fullName[0].toUpperCase(),
                                          style: TextStyle(
                                            color: ShadcnColors.accent700,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedPatient!.fullName,
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: ShadcnColors.accent800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_selectedPatient!.age} years • ${_selectedPatient!.bloodGroup} • ${_selectedPatient!.cnic}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: ShadcnColors.accent600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Latest Vitals Display
                                if (_patientVitals.isNotEmpty) ...[
                                  Text(
                                    'Latest Vitals',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: _buildVitalsDisplay(_patientVitals.first),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.orange.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.orange.shade700,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'No vitals recorded for this patient. Please collect vitals first.',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Diagnosis and Prescription Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Diagnosis Panel
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Diagnosis',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ShadcnColors.accent700,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Disease Search Field
                                    Autocomplete<Disease>(
                                      optionsBuilder: (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text.isEmpty) {
                                          return _allDiseases.take(10);
                                        }
                                        return _filteredDiseases.take(10);
                                      },
                                      displayStringForOption: (Disease disease) => disease.name,
                                      onSelected: (Disease disease) {
                                        setState(() {
                                          _selectedDisease = disease;
                                          _diseaseController.text = disease.name;
                                        });
                                      },
                                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                        return TextFormField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText: 'Search Disease',
                                            hintText: 'Type to search diseases...',
                                            border: OutlineInputBorder(),
                                            prefixIcon: Icon(Icons.search),
                                            suffixIcon: Icon(Icons.arrow_drop_down),
                                          ),
                                          onChanged: (value) {
                                            _filterDiseases();
                                          },
                                          validator: (value) {
                                            if (_selectedDisease == null) {
                                              return 'Please select a disease';
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                      optionsViewBuilder: (context, onSelected, options) {
                                        return Align(
                                          alignment: Alignment.topLeft,
                                          child: Material(
                                            elevation: 4,
                                            borderRadius: BorderRadius.circular(8),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(maxHeight: 300),
                                              child: ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                itemCount: options.length,
                                                itemBuilder: (context, index) {
                                                  final disease = options.elementAt(index);
                                                  return ListTile(
                                                    dense: true,
                                                    leading: Icon(
                                                      _getDiseaseIcon(disease.category),
                                                      size: 20,
                                                      color: ShadcnColors.accent700,
                                                    ),
                                                    title: Text(
                                                      disease.name,
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                    subtitle: Text(
                                                      '${disease.category} • ${disease.icdCode}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      onSelected(disease);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _followupDateController,
                                      decoration: const InputDecoration(
                                        labelText: 'Followup Date',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                        );
                                        if (date != null) {
                                          _followupDateController.text = 
                                              '${date.day}/${date.month}/${date.year}';
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _doctorNotesController,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        labelText: 'Doctor\'s Notes',
                                        border: OutlineInputBorder(),
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Prescription Panel
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prescription',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ShadcnColors.accent700,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Prescription Table Headers
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Name',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Instructions',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Prescription List
                                    Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: _prescriptions.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No Medicine Prescribed',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: _prescriptions.length,
                                              itemBuilder: (context, index) {
                                                final prescription = _prescriptions[index];
                                                return Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Colors.grey.shade200,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(prescription['name'] ?? ''),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(prescription['instructions'] ?? ''),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _prescriptions.removeAt(index);
                                                          });
                                                        },
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: Colors.red.shade50,
                                                          foregroundColor: Colors.red,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        icon: const Icon(Icons.delete),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Add Medicine Form
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: DropdownButtonFormField<String>(
                                            value: _selectedMedicine,
                                            decoration: const InputDecoration(
                                              labelText: 'Select Medicine',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            ),
                                            isExpanded: true,
                                            items: _availableMedicines.map((String medicine) {
                                              return DropdownMenuItem<String>(
                                                value: medicine,
                                                child: Text(
                                                  medicine,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedMedicine = newValue;
                                                _medicineNameController.text = newValue ?? '';
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please select a medicine';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            controller: _medicineInstructionsController,
                                            decoration: const InputDecoration(
                                              labelText: 'Instructions',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 72,
                                            maxWidth: 96,
                                            minHeight: 40,
                                            maxHeight: 44,
                                          ),
                                          child: FilledButton(
                                            onPressed: _addPrescription,
                                            style: FilledButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              backgroundColor: ThemeController.instance.useShadcn.value
                                                  ? ShadcnColors.accent
                                                  : Colors.green.shade600,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            child: const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'ADD',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Action Buttons
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child:                         Row(
                            children: [
                              // Refer Patient Button
                              SizedBox(
                                width: 200,
                                height: 56,
                                child: FilledButton(
                                  onPressed: () {
                                    // TODO: Implement refer functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Refer coming soon')),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    textStyle: theme.textTheme.titleMedium,
                                  ),
                                  child: const Text('Refer Patient'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Lab Reports Button (moved next to Refer)
                              SizedBox(
                                width: 200,
                                height: 56,
                                child: FilledButton(
                                  onPressed: () => _showLabReportsModal(context),
                                  style: FilledButton.styleFrom(
                                    textStyle: theme.textTheme.titleMedium,
                                  ),
                                  child: const Text('Lab Reports'),
                                ),
                              ),
                              const Spacer(),
                              // Cancel (Outlined) Button
                              SizedBox(
                                width: 160,
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    textStyle: theme.textTheme.titleMedium,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Save Diagnosis Button
                              SizedBox(
                                width: 200,
                                height: 56,
                                child: FilledButton(
                                  onPressed: _saveDiagnosis,
                                  style: FilledButton.styleFrom(
                                    textStyle: theme.textTheme.titleMedium,
                                  ),
                                  child: const Text('Save Diagnosis'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsDisplay(VitalsRecord vitals) {
    return Row(
      children: [
        // Temperature
        Expanded(
          child: _buildVitalCard(
            'Temperature',
            '${vitals.temperature?.toStringAsFixed(1) ?? 'N/A'}°F',
            Icons.thermostat,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        // Pulse
        Expanded(
          child: _buildVitalCard(
            'Pulse',
            '${vitals.pulse?.toString() ?? 'N/A'} bpm',
            Icons.favorite,
            Colors.pink,
          ),
        ),
        const SizedBox(width: 12),
        // Blood Pressure
        Expanded(
          child: _buildVitalCard(
            'Blood Pressure',
            '${vitals.systolic}/${vitals.diastolic}',
            Icons.monitor_heart,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        // Weight
        Expanded(
          child: _buildVitalCard(
            'Weight',
            '${vitals.weight.toStringAsFixed(1)} kg',
            Icons.monitor_weight,
            ShadcnColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        // Height
        Expanded(
          child: _buildVitalCard(
            'Height',
            '${vitals.height.toStringAsFixed(0)} cm',
            Icons.height,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _addPrescription() {
    if (_selectedMedicine != null && 
        _medicineInstructionsController.text.isNotEmpty) {
      setState(() {
        _prescriptions.add({
          'name': _selectedMedicine!,
          'instructions': _medicineInstructionsController.text,
        });
        _selectedMedicine = null;
        _medicineNameController.clear();
        _medicineInstructionsController.clear();
      });
    }
  }

  void _saveDiagnosis() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save diagnosis functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diagnosis saved successfully'),
          backgroundColor: ShadcnColors.accent,
        ),
      );
    }
  }

  void _showLabReportsModal(BuildContext context) {
    _labListVisibleCount = 5;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedPadding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.science,
                        color: ShadcnColors.accent700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Laboratory Reports',
                          style: TextStyle(
                            color: ShadcnColors.accent700,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: ShadcnColors.accent700,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Patient Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ShadcnColors.accent50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ShadcnColors.accent200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: ShadcnColors.accent100,
                                child: Icon(
                                  Icons.person,
                                  color: ShadcnColors.accent700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedPatient?.fullName ?? 'No Patient Selected',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ShadcnColors.accent700,
                                      ),
                                    ),
                                    Text(
                                      'CNIC: ${_selectedPatient?.cnic ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ShadcnColors.accent600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Search Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Search Lab Tests',
                            hintText: 'Type to search tests...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              _searchQuery = value;
                              _labListVisibleCount = 5;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Test Type Selection Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _selectedTestType == 'individual'
                                  ? FilledButton(
                                      onPressed: () {},
                                      style: FilledButton.styleFrom(
                                        backgroundColor: ShadcnColors.accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Individual Tests'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () {
                                        setModalState(() {
                                          _selectedTestType = 'individual';
                                          _labListVisibleCount = 5;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade700,
                                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Individual Tests'),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _selectedTestType == 'package'
                                  ? FilledButton(
                                      onPressed: () {},
                                      style: FilledButton.styleFrom(
                                        backgroundColor: ShadcnColors.accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Package Tests'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () {
                                        setModalState(() {
                                          _selectedTestType = 'package';
                                          _labListVisibleCount = 5;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade700,
                                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Package Tests'),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Lab Tests Section
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTestType == 'individual' 
                                      ? 'Individual Lab Tests' 
                                      : 'Package Lab Tests',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ShadcnColors.accent700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Lab Tests List
                                _buildLabTestsList(setModalState),
                              ],
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 200,
                        height: 56,
                        child: FilledButton(
                          onPressed: () {
                            // TODO: Implement order lab tests
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                            backgroundColor: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent
                                : Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Order Lab Tests'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
          },
        );
      },
    );
  }

  Widget _buildLabTestCard(String title, String code, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            code,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabTestsList(StateSetter setModalState) {
    final tests = _selectedTestType == 'individual' ? _individualTests : _packageTests;
    final filteredTests = _searchQuery.isEmpty 
        ? tests 
        : tests.where((test) => 
            test.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    if (filteredTests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No tests found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final int itemCount = _labListVisibleCount < filteredTests.length 
        ? _labListVisibleCount 
        : filteredTests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final test = filteredTests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: _selectedTestType == 'individual' 
                      ? Colors.blue.shade100 
                      : ShadcnColors.accent100,
                  child: Icon(
                    _selectedTestType == 'individual' 
                        ? Icons.science 
                        : Icons.inventory,
                    color: _selectedTestType == 'individual' 
                        ? Colors.blue.shade700 
                        : ShadcnColors.accent700,
                    size: 20,
                  ),
                ),
                title: Text(
                  test,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                subtitle: Text(
                  _selectedTestType == 'individual' 
                      ? 'Individual Test' 
                      : 'Package Test',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: _selectedLabTests.contains(test)
                      ? IconButton(
                          key: ValueKey('check_$test'),
                          onPressed: () {
                            setModalState(() {
                              _selectedLabTests.remove(test);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed $test from order'),
                                backgroundColor: Colors.grey.shade700,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.check_circle,
                            color: ShadcnColors.accent600,
                          ),
                        )
                      : IconButton(
                          key: ValueKey('add_$test'),
                          onPressed: () {
                            setModalState(() {
                              _selectedLabTests.add(test);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added $test to order'),
                                backgroundColor: ShadcnColors.accent,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: ShadcnColors.accent600,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
        if (filteredTests.length > itemCount) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 160,
              height: 40,
              child: OutlinedButton(
                onPressed: () {
                  setModalState(() {
                    _labListVisibleCount += 5;
                  });
                },
                child: const Text('Load more'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
