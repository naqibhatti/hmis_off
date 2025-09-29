import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';
import '../services/patient_data_service.dart';
import '../services/vitals_storage_service.dart';
import '../models/patient_data.dart';

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
  final _followupDateController = TextEditingController();
  final _doctorNotesController = TextEditingController();
  
  // Prescription Controllers
  final _medicineNameController = TextEditingController();
  final _medicineInstructionsController = TextEditingController();
  
  List<Map<String, String>> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _diseaseController.dispose();
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
      body: Column(
        children: <Widget>[
          // Header section
          CommonHeader(
            title: 'Diagnosis & Prescription',
            userAccessLevel: 'Doctor',
          ),
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
                            // Patient Selection Dropdown
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<PatientData>(
                                    value: _selectedPatient,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Patient',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    items: _allPatients.map((patient) {
                                      return DropdownMenuItem<PatientData>(
                                        value: patient,
                                        child: Text('${patient.fullName} (${patient.cnic})'),
                                      );
                                    }).toList(),
                                    onChanged: (PatientData? newValue) {
                                      setState(() {
                                        _selectedPatient = newValue;
                                        _loadPatientVitals();
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select a patient';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 120,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement test reports functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Test Reports feature coming soon')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Test Reports'),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedPatient != null) ...[
                              const SizedBox(height: 20),
                              // Patient Info Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        _selectedPatient!.fullName[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
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
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_selectedPatient!.age} years • ${_selectedPatient!.bloodGroup} • ${_selectedPatient!.cnic}',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.blue.shade600,
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
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _diseaseController,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Disease',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter disease';
                                      }
                                      return null;
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
                                      color: Colors.green.shade700,
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
                                                      icon: const Icon(Icons.delete, color: Colors.red),
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
                                        child: TextFormField(
                                          controller: _medicineNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Medicine Name',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
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
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: _addPrescription,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('ADD'),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement refer functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Refer feature coming soon')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Refer Patient',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _saveDiagnosis,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Save Diagnosis',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
            Colors.green,
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
    if (_medicineNameController.text.isNotEmpty && 
        _medicineInstructionsController.text.isNotEmpty) {
      setState(() {
        _prescriptions.add({
          'name': _medicineNameController.text,
          'instructions': _medicineInstructionsController.text,
        });
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
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
