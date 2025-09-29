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

  // Normal health ranges for vital signs
  static const Map<String, VitalRange> _vitalRanges = {
    'systolic': VitalRange(normal: Range(90, 120), warning: Range(80, 140), critical: Range(50, 180)),
    'diastolic': VitalRange(normal: Range(60, 80), warning: Range(50, 90), critical: Range(30, 110)),
    'pulse': VitalRange(normal: Range(60, 100), warning: Range(50, 110), critical: Range(40, 120)),
    'temperature': VitalRange(normal: Range(97.0, 99.5), warning: Range(96.0, 100.4), critical: Range(95.0, 101.0)),
    'weight': VitalRange(normal: Range(50, 100), warning: Range(40, 120), critical: Range(30, 150)),
    'height': VitalRange(normal: Range(150, 190), warning: Range(140, 200), critical: Range(120, 220)),
  };

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
        // Trigger validation and UI update
        _formKey.currentState?.validate();
        setState(() {}); // Update UI to show color changes
      }
    }
  }

  // Get color for vital sign value
  Color _getVitalColor(String vitalType, String value) {
    if (value.isEmpty) return Colors.grey;
    
    final double? numValue = double.tryParse(value);
    if (numValue == null) return Colors.grey;
    
    final vitalRange = _vitalRanges[vitalType];
    if (vitalRange == null) return Colors.grey;
    
    final severity = vitalRange.getSeverity(numValue);
    return severity.color;
  }

  // Get severity for vital sign value
  VitalSeverity _getVitalSeverity(String vitalType, String value) {
    if (value.isEmpty) return VitalSeverity.normal;
    
    final double? numValue = double.tryParse(value);
    if (numValue == null) return VitalSeverity.normal;
    
    final vitalRange = _vitalRanges[vitalType];
    if (vitalRange == null) return VitalSeverity.normal;
    
    return vitalRange.getSeverity(numValue);
  }

  // Check if vital value is abnormal
  bool _isVitalAbnormal(String vitalType, String value) {
    final severity = _getVitalSeverity(vitalType, value);
    return severity != VitalSeverity.normal;
  }

  // Build status chip for vital sign summary
  Widget _buildVitalStatusChip(String label, String value, String vitalType) {
    if (value.isEmpty) {
      return Chip(
        label: Text('$label: --'),
        backgroundColor: Colors.grey.shade200,
        labelStyle: const TextStyle(color: Colors.grey),
      );
    }

    final severity = _getVitalSeverity(vitalType, value);
    final color = severity.color;
    
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
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
                      // Vital Signs Status Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.health_and_safety,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Vital Signs Status',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildVitalStatusChip('Systolic', _systolicController.text, 'systolic'),
                                _buildVitalStatusChip('Diastolic', _diastolicController.text, 'diastolic'),
                                _buildVitalStatusChip('Pulse', _pulseController.text, 'pulse'),
                                _buildVitalStatusChip('Temperature', _temperatureController.text, 'temperature'),
                                _buildVitalStatusChip('Weight', _weightController.text, 'weight'),
                                _buildVitalStatusChip('Height', _heightController.text, 'height'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Blood Pressure Row
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _systolicController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(
                                color: _getVitalColor('systolic', _systolicController.text),
                                fontWeight: _isVitalAbnormal('systolic', _systolicController.text) 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Systolic (50-250) *',
                                border: OutlineInputBorder(),
                                suffixIcon: _isVitalAbnormal('systolic', _systolicController.text)
                                    ? Icon(
                                        Icons.warning,
                                        color: _getVitalColor('systolic', _systolicController.text),
                                        size: 20,
                                      )
                                    : null,
                                helperText: _isVitalAbnormal('systolic', _systolicController.text)
                                    ? '${_getVitalSeverity('systolic', _systolicController.text).label} - Outside normal range'
                                    : 'Normal range: 90-120 mmHg',
                                helperStyle: TextStyle(
                                  color: _getVitalColor('systolic', _systolicController.text),
                                  fontSize: 12,
                                ),
                              ),
                              validator: (value) => _rangeValidator(value, 50, 250, 'Systolic'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_systolicController, 50, 250, 'Systolic'),
                              onChanged: (value) => setState(() {}), // Update UI on change
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
                              style: TextStyle(
                                color: _getVitalColor('diastolic', _diastolicController.text),
                                fontWeight: _isVitalAbnormal('diastolic', _diastolicController.text) 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Diastolic (30-200) *',
                                border: OutlineInputBorder(),
                                suffixIcon: _isVitalAbnormal('diastolic', _diastolicController.text)
                                    ? Icon(
                                        Icons.warning,
                                        color: _getVitalColor('diastolic', _diastolicController.text),
                                        size: 20,
                                      )
                                    : null,
                                helperText: _isVitalAbnormal('diastolic', _diastolicController.text)
                                    ? '${_getVitalSeverity('diastolic', _diastolicController.text).label} - Outside normal range'
                                    : 'Normal range: 60-80 mmHg',
                                helperStyle: TextStyle(
                                  color: _getVitalColor('diastolic', _diastolicController.text),
                                  fontSize: 12,
                                ),
                              ),
                              validator: (value) => _rangeValidator(value, 30, 200, 'Diastolic'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_diastolicController, 30, 200, 'Diastolic'),
                              onChanged: (value) => setState(() {}), // Update UI on change
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
                              style: TextStyle(
                                color: _getVitalColor('weight', _weightController.text),
                                fontWeight: _isVitalAbnormal('weight', _weightController.text) 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Weight (1-220) (kg) *',
                                border: OutlineInputBorder(),
                                suffixIcon: _isVitalAbnormal('weight', _weightController.text)
                                    ? Icon(
                                        Icons.warning,
                                        color: _getVitalColor('weight', _weightController.text),
                                        size: 20,
                                      )
                                    : null,
                                helperText: _isVitalAbnormal('weight', _weightController.text)
                                    ? '${_getVitalSeverity('weight', _weightController.text).label} - Outside normal range'
                                    : 'Normal range: 50-100 kg',
                                helperStyle: TextStyle(
                                  color: _getVitalColor('weight', _weightController.text),
                                  fontSize: 12,
                                ),
                              ),
                              validator: (value) => _rangeValidator(value, 1, 220, 'Weight'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_weightController, 1, 220, 'Weight'),
                              onChanged: (value) => setState(() {}), // Update UI on change
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _temperatureController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(
                                color: _getVitalColor('temperature', _temperatureController.text),
                                fontWeight: _isVitalAbnormal('temperature', _temperatureController.text) 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Temperature (96-106) (°F)',
                                border: OutlineInputBorder(),
                                suffixIcon: _isVitalAbnormal('temperature', _temperatureController.text)
                                    ? Icon(
                                        Icons.warning,
                                        color: _getVitalColor('temperature', _temperatureController.text),
                                        size: 20,
                                      )
                                    : null,
                                helperText: _isVitalAbnormal('temperature', _temperatureController.text)
                                    ? '${_getVitalSeverity('temperature', _temperatureController.text).label} - Outside normal range'
                                    : 'Normal range: 97.0-99.5°F',
                                helperStyle: TextStyle(
                                  color: _getVitalColor('temperature', _temperatureController.text),
                                  fontSize: 12,
                                ),
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
                              onChanged: (value) => setState(() {}), // Update UI on change
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
                              style: TextStyle(
                                color: _getVitalColor('pulse', _pulseController.text),
                                fontWeight: _isVitalAbnormal('pulse', _pulseController.text) 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Pulse (60-100) (bpm)',
                                border: OutlineInputBorder(),
                                suffixIcon: _isVitalAbnormal('pulse', _pulseController.text)
                                    ? Icon(
                                        Icons.warning,
                                        color: _getVitalColor('pulse', _pulseController.text),
                                        size: 20,
                                      )
                                    : null,
                                helperText: _isVitalAbnormal('pulse', _pulseController.text)
                                    ? '${_getVitalSeverity('pulse', _pulseController.text).label} - Outside normal range'
                                    : 'Normal range: 60-100 bpm',
                                helperStyle: TextStyle(
                                  color: _getVitalColor('pulse', _pulseController.text),
                                  fontSize: 12,
                                ),
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
                              onChanged: (value) => setState(() {}), // Update UI on change
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(
                                color: _getVitalColor('height', _heightController.text),
                                fontWeight: _isVitalAbnormal('height', _heightController.text) 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Height (cm) *',
                                border: OutlineInputBorder(),
                                suffixIcon: _isVitalAbnormal('height', _heightController.text)
                                    ? Icon(
                                        Icons.warning,
                                        color: _getVitalColor('height', _heightController.text),
                                        size: 20,
                                      )
                                    : null,
                                helperText: _isVitalAbnormal('height', _heightController.text)
                                    ? '${_getVitalSeverity('height', _heightController.text).label} - Outside normal range'
                                    : 'Normal range: 150-190 cm',
                                helperStyle: TextStyle(
                                  color: _getVitalColor('height', _heightController.text),
                                  fontSize: 12,
                                ),
                              ),
                              validator: (value) => _rangeValidator(value, 50, 250, 'Height'),
                              onFieldSubmitted: (value) => _onFieldSubmitted(_heightController, 50, 250, 'Height'),
                              onChanged: (value) => setState(() {}), // Update UI on change
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

// Data classes for vital sign ranges
class Range {
  final double min;
  final double max;
  
  const Range(this.min, this.max);
  
  bool contains(double value) => value >= min && value <= max;
}

class VitalRange {
  final Range normal;
  final Range warning;
  final Range critical;
  
  const VitalRange({
    required this.normal,
    required this.warning,
    required this.critical,
  });
  
  VitalSeverity getSeverity(double value) {
    if (normal.contains(value)) return VitalSeverity.normal;
    if (warning.contains(value)) return VitalSeverity.warning;
    return VitalSeverity.critical;
  }
}

enum VitalSeverity {
  normal,
  warning,
  critical,
}

extension VitalSeverityExtension on VitalSeverity {
  Color get color {
    switch (this) {
      case VitalSeverity.normal:
        return Colors.green;
      case VitalSeverity.warning:
        return Colors.orange;
      case VitalSeverity.critical:
        return Colors.red;
    }
  }
  
  String get label {
    switch (this) {
      case VitalSeverity.normal:
        return 'Normal';
      case VitalSeverity.warning:
        return 'Warning';
      case VitalSeverity.critical:
        return 'Critical';
    }
  }
}
