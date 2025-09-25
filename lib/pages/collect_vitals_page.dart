import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import 'vitals_pdf_preview_page.dart';
import '../models/patient_data.dart';

class CollectVitalsPage extends StatefulWidget {
  final String? patientName;
  final int? patientAge;
  final String? patientBloodGroup;

  const CollectVitalsPage({
    super.key,
    this.patientName,
    this.patientAge,
    this.patientBloodGroup,
  });

  @override
  State<CollectVitalsPage> createState() => _CollectVitalsPageState();
}

class _CollectVitalsPageState extends State<CollectVitalsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create vitals data
      final vitals = VitalsData(
        systolic: int.parse(_systolicController.text.trim()),
        diastolic: int.parse(_diastolicController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        temperature: double.parse(_temperatureController.text.trim()),
        pulse: int.parse(_pulseController.text.trim()),
        height: double.parse(_heightController.text.trim()),
      );

      // Show success dialog and navigate to PDF preview
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Vitals Collected'),
          content: const Text('Patient vitals have been successfully recorded.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                final patient = PatientManager.currentPatient;
                if (patient == null) {
                  // Create a default patient for PDF generation
                  final defaultPatient = PatientData(
                    fullName: 'Unknown Patient',
                    age: 0,
                    bloodGroup: 'Unknown',
                    email: '',
                    phone: '',
                    address: '',
                    cnic: '',
                    gender: '',
                    dateOfBirth: DateTime.now(),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VitalsPdfPreviewPage(
                        vitals: vitals,
                        patient: defaultPatient,
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VitalsPdfPreviewPage(
                        vitals: vitals,
                        patient: patient,
                      ),
                    ),
                  );
                }
              },
              child: const Text('View Report'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to dashboard
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  String? _requiredValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _rangeValidator(String? value, int min, int max, String fieldName) {
    final String? requiredResult = _requiredValidator(value, fieldName: fieldName);
    if (requiredResult != null) return requiredResult;
    
    final double? numValue = double.tryParse(value!);
    if (numValue == null) {
      return 'Enter a valid number';
    }
    if (numValue < min || numValue > max) {
      return 'Value must be between $min-$max';
    }
    return null;
  }

  void _validateAndFormatField(TextEditingController controller, int min, int max, String fieldName) {
    final String value = controller.text;
    if (value.isNotEmpty) {
      final double? numValue = double.tryParse(value);
      if (numValue != null) {
        if (numValue < min) {
          controller.text = min.toString();
        } else if (numValue > max) {
          controller.text = max.toString();
        }
        // Trigger validation
        _formKey.currentState?.validate();
      }
    }
  }

  void _onFieldSubmitted(TextEditingController controller, int min, int max, String fieldName) {
    final String value = controller.text;
    if (value.isNotEmpty) {
      final double? numValue = double.tryParse(value);
      if (numValue != null) {
        if (numValue < min) {
          controller.text = min.toString();
        } else if (numValue > max) {
          controller.text = max.toString();
        }
        // Trigger validation
        _formKey.currentState?.validate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Header section
          CommonHeader(
            title: 'Collect Vitals',
            userAccessLevel: 'Doctor',
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Patient Information Card
                      if (widget.patientName != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                color: Colors.blue.shade700,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Patient: ${widget.patientName}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    if (widget.patientAge != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Age: ${widget.patientAge} years',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade600,
                                        ),
                                      ),
                                    ],
                                    if (widget.patientBloodGroup != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Blood Group: ${widget.patientBloodGroup}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        // No patient selected message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'No patient selected. Vitals will be recorded without patient information.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Blood Pressure Row
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _systolicController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Systolic (50-250) *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => _rangeValidator(value, 50, 250, 'Systolic'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_systolicController, 50, 250, 'Systolic'),
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
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Diastolic (30-200) *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => _rangeValidator(value, 30, 200, 'Diastolic'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_diastolicController, 30, 200, 'Diastolic'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Weight and Temperature Row
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Weight (1-220) (kg) *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => _rangeValidator(value, 1, 220, 'Weight'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_weightController, 1, 220, 'Weight'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _temperatureController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Temperature (96-106) (°F)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return _rangeValidator(value, 96, 106, 'Temperature');
                                }
                                return null; // Temperature is optional
                              },
                              onFieldSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _onFieldSubmitted(_temperatureController, 96, 106, 'Temperature');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Pulse and Height Row
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _pulseController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Pulse (60-100) (bpm)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return _rangeValidator(value, 60, 100, 'Pulse');
                                }
                                return null; // Pulse is optional
                              },
                              onFieldSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _onFieldSubmitted(_pulseController, 60, 100, 'Pulse');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Height (cm) *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => _rangeValidator(value, 50, 250, 'Height'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_heightController, 50, 250, 'Height'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Save button - fixed width and right-aligned
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 200,
                          height: 56,
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              textStyle: theme.textTheme.titleMedium,
                            ),
                            child: const Text('Save Vitals'),
                          ),
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
}
