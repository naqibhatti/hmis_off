import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';

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
  
  // Patient Vitals Controllers
  final _patientNameController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _pulseController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
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
    if (widget.patientName != null) {
      _patientNameController.text = widget.patientName!;
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _diseaseController.dispose();
    _followupDateController.dispose();
    _doctorNotesController.dispose();
    _medicineNameController.dispose();
    _medicineInstructionsController.dispose();
    super.dispose();
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
                      // Patient Vitals Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient Vitals',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Patient Name
                            TextFormField(
                              controller: _patientNameController,
                              decoration: const InputDecoration(
                                labelText: 'Patient Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter patient name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Vitals Row 1: Temperature and Pulse
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _temperatureController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Temperature (96-106) (°F)',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => _rangeValidator(value, 96, 106, 'Temperature'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _pulseController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Pulse (60-100) (bpm)',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => _rangeValidator(value, 60, 100, 'Pulse'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Blood Pressure Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _systolicController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Systolic (50-250) *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => _rangeValidator(value, 50, 250, 'Systolic'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '/',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _diastolicController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Diastolic (30-200) *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => _rangeValidator(value, 30, 200, 'Diastolic'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Height and Weight Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Height (cm) *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => _rangeValidator(value, 50, 250, 'Height'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Weight (1-220) (kg) *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => _rangeValidator(value, 1, 220, 'Weight'),
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
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
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
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
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
                              ),
                              child: const Text('Refer'),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveDiagnosis,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
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

  String? _rangeValidator(String? value, double min, double max, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    final double? numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Enter a valid number';
    }
    if (numValue < min || numValue > max) {
      return 'Value must be between $min-$max';
    }
    return null;
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
