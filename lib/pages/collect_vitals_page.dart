import 'package:flutter/material.dart';
import 'vitals_pdf_preview_page.dart';
import '../models/patient_data.dart';
import '../services/patient_data_service.dart';
import '../services/vitals_storage_service.dart';
import '../theme/shadcn_colors.dart';
import '../widgets/side_navigation_drawer.dart';
import '../models/patient_data.dart' show PatientManager;

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

  // Patient selection
  PatientData? _selectedPatient;
  List<PatientData> _allPatients = [];
  List<PatientData> _filteredPatients = [];
  final TextEditingController _patientSearchController = TextEditingController();

  // Vitals history
  List<VitalsRecord> _patientVitalsHistory = [];
  late VoidCallback _vitalsListener;

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
  void initState() {
    super.initState();
    _loadPatients();
    _patientSearchController.addListener(_filterPatients);
    
    // Set up vitals listener
    _vitalsListener = () {
      if (mounted) {
        _loadPatientVitals();
      }
    };
    VitalsStorageService.addListener(_vitalsListener);
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _heightController.dispose();
    _patientSearchController.dispose();
    VitalsStorageService.removeListener(_vitalsListener);
    super.dispose();
  }

  void _loadPatients() {
    setState(() {
      _allPatients = PatientDataService.allPatients;
      _filteredPatients = _allPatients;
      
      // If patient info was passed from previous screen, try to find the patient
      if (widget.patientName != null) {
        _selectedPatient = _allPatients.firstWhere(
          (p) => p.fullName == widget.patientName,
          orElse: () => _allPatients.first, // Fallback to first patient
        );
        _loadPatientVitals();
      }
    });
  }

  void _loadPatientVitals() {
    if (_selectedPatient != null) {
      setState(() {
        _patientVitalsHistory = VitalsStorageService.getPatientVitals(_selectedPatient!.cnic);
      });
    }
  }

  void _filterPatients() {
    final query = _patientSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((patient) {
          return patient.fullName.toLowerCase().contains(query) ||
                 patient.cnic.contains(query) ||
                 patient.contactNumber.contains(query);
        }).toList();
      }
    });
  }

  void _submit() {
    // If any values are outside acceptable ranges, show error popup and block submit
    final List<String> outOfRange = _collectOutOfRangeErrors();
    if (outOfRange.isNotEmpty) {
      _showOutOfRangeErrorsDialog(outOfRange);
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Create vitals data
      final vitals = VitalsData(
        systolic: int.parse(_systolicController.text.trim()),
        diastolic: int.parse(_diastolicController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        temperature: _temperatureController.text.trim().isNotEmpty 
            ? double.parse(_temperatureController.text.trim()) 
            : 0.0,
        pulse: _pulseController.text.trim().isNotEmpty 
            ? int.parse(_pulseController.text.trim()) 
            : 0,
        height: double.parse(_heightController.text.trim()),
      );

      // Save vitals to storage
      if (_selectedPatient != null) {
        final vitalsRecord = VitalsRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientCnic: _selectedPatient!.cnic,
          systolic: vitals.systolic,
          diastolic: vitals.diastolic,
          weight: vitals.weight,
          temperature: vitals.temperature > 0 ? vitals.temperature : null,
          pulse: vitals.pulse > 0 ? vitals.pulse : null,
          height: vitals.height,
          recordedAt: DateTime.now(),
          recordedBy: 'Doctor', // You can make this dynamic based on user type
        );
        VitalsStorageService.addVitalsRecord(vitalsRecord);
      }

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
                final patient = _selectedPatient ?? PatientManager.currentPatient;
                if (patient == null) {
                  // Create a default patient for PDF generation
                  final defaultPatient = PatientData(
                    fullName: 'Unknown Patient',
                    age: 0,
                    bloodGroup: 'Unknown',
                    email: '',
                    contactNumber: '',
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
    final String value = controller.text.trim();
    if (value.isEmpty) return;
    final double? numValue = double.tryParse(value);
    if (numValue == null) return;
    if (numValue < min || numValue > max) {
      _showOutOfRangeError(fieldName, '$min-$max');
      controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      return;
    }
    _formKey.currentState?.validate();
    setState(() {});
  }

  List<String> _collectOutOfRangeErrors() {
    final List<String> errors = [];
    void check(TextEditingController c, int min, int max, String label, {bool optional = false}) {
      final String t = c.text.trim();
      if (t.isEmpty) {
        if (!optional) {
          // Let validator handle required state
        }
        return;
      }
      final double? v = double.tryParse(t);
      if (v == null) return;
      if (v < min || v > max) {
        errors.add('$label must be in $min-$max');
      }
    }

    check(_systolicController, 50, 250, 'Systolic');
    check(_diastolicController, 30, 200, 'Diastolic');
    check(_weightController, 1, 220, 'Weight');
    check(_heightController, 50, 250, 'Height');
    check(_temperatureController, 96, 106, 'Temperature', optional: true);
    check(_pulseController, 60, 100, 'Pulse', optional: true);
    return errors;
  }

  void _showOutOfRangeError(String fieldName, String range) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Value'),
        content: Text('$fieldName is outside the allowed range ($range). Please correct the value.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showOutOfRangeErrorsDialog(List<String> errors) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Please correct these fields'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('• $e'),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
    // Neutral styling for Weight and Height
    if (value.isEmpty) {
      return Chip(
        label: Text('$label: --'),
        backgroundColor: Colors.grey.shade200,
        labelStyle: const TextStyle(color: Colors.grey),
      );
    }

    if (vitalType == 'weight' || vitalType == 'height') {
      return Chip(
        label: Text('$label: $value'),
        backgroundColor: Colors.grey.shade200,
        side: BorderSide(color: Colors.grey.shade400, width: 1),
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
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

  // Build vitals display for history records (similar to diagnostic page)
  Widget _buildVitalsDisplayForHistory(VitalsRecord record) {
    final isRecent = DateTime.now().difference(record.recordedAt).inDays < 7;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and recorded by info
        Row(
          children: [
            Icon(
              Icons.favorite,
              color: isRecent ? ShadcnColors.accent600 : Colors.grey.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(record.recordedAt),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isRecent ? ShadcnColors.accent700 : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              'By: ${record.recordedBy}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Vitals display in one row
        Row(
          children: [
            Expanded(
              child: _buildVitalCardForHistory(
                'Temperature',
                '${record.temperature?.toStringAsFixed(1) ?? 'N/A'}°F',
                Icons.thermostat,
                Colors.red,
                'temperature',
                record.temperature?.toString() ?? '',
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildVitalCardForHistory(
                'Pulse',
                '${record.pulse?.toString() ?? 'N/A'} bpm',
                Icons.favorite,
                Colors.pink,
                'pulse',
                record.pulse?.toString() ?? '',
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildVitalCardForHistory(
                'Blood Pressure',
                '${record.systolic}/${record.diastolic}',
                Icons.monitor_heart,
                Colors.blue,
                'systolic',
                record.systolic.toString(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildVitalCardForHistory(
                'Weight',
                '${record.weight.toStringAsFixed(1)} kg',
                Icons.monitor_weight,
                ShadcnColors.accent,
                'weight',
                record.weight.toString(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildVitalCardForHistory(
                'Height',
                '${record.height.toStringAsFixed(0)} cm',
                Icons.height,
                Colors.purple,
                'height',
                record.height.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build vital card for history display
  Widget _buildVitalCardForHistory(String label, String value, IconData icon, Color color, String vitalType, String valueString) {
    final bool isNeutral = vitalType == 'weight' || vitalType == 'height';
    final vitalColor = isNeutral ? Colors.grey.shade700 : _getVitalColor(vitalType, valueString);
    final isAbnormal = isNeutral ? false : _isVitalAbnormal(vitalType, valueString);
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: vitalColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: vitalColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: vitalColor, size: 14),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: vitalColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 9,
              color: vitalColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (isAbnormal)
            Icon(
              Icons.warning,
              size: 8,
              color: vitalColor,
            ),
        ],
      ),
    );
  }

  // Build vitals history card
  Widget _buildVitalsHistoryCard(VitalsRecord record) {
    final theme = Theme.of(context);
    final isRecent = DateTime.now().difference(record.recordedAt).inDays < 7;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRecent ? ShadcnColors.accent300 : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: isRecent ? ShadcnColors.accent600 : Colors.grey.shade600,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatDate(record.recordedAt),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isRecent ? ShadcnColors.accent700 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCompactVitalRow('BP', '${record.systolic}/${record.diastolic}', 'systolic', record.systolic.toString()),
          _buildCompactVitalRow('Weight', '${record.weight}kg', 'weight', record.weight.toString()),
          if (record.temperature != null)
            _buildCompactVitalRow('Temp', '${record.temperature}°F', 'temperature', record.temperature.toString()),
          if (record.pulse != null)
            _buildCompactVitalRow('Pulse', '${record.pulse}bpm', 'pulse', record.pulse.toString()),
          _buildCompactVitalRow('Height', '${record.height}cm', 'height', record.height.toString()),
          const SizedBox(height: 6),
          Text(
            'By: ${record.recordedBy}',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Build compact vital row for history cards
  Widget _buildCompactVitalRow(String label, String value, String vitalType, String valueString) {
    final bool isNeutral = vitalType == 'weight' || vitalType == 'height';
    final color = isNeutral ? Colors.grey.shade700 : _getVitalColor(vitalType, valueString);
    final isAbnormal = isNeutral ? false : _isVitalAbnormal(vitalType, valueString);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isAbnormal)
            Icon(
              Icons.warning,
              size: 10,
              color: color,
            ),
        ],
      ),
    );
  }

  // Build individual vital row in history card
  Widget _buildVitalRow(String label, String value, String vitalType, String valueString) {
    final bool isNeutral = vitalType == 'weight' || vitalType == 'height';
    final color = isNeutral ? Colors.grey.shade700 : _getVitalColor(vitalType, valueString);
    final isAbnormal = isNeutral ? false : _isVitalAbnormal(vitalType, valueString);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isAbnormal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isAbnormal)
            Icon(
              Icons.warning,
              size: 16,
              color: color,
            ),
        ],
      ),
    );
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SideNavigationDrawer(
        currentRoute: '/collect-vitals',
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
                        // Removed duplicate Selected Patient display to avoid repetition
                        const SizedBox(height: 16),
                        // Patient Information Card
                        if ((_selectedPatient ?? PatientManager.currentPatient) != null) ...[
                          Container(
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
                                    ((_selectedPatient ?? PatientManager.currentPatient)!.fullName[0]).toUpperCase(),
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
                                        'Patient: ${(_selectedPatient ?? PatientManager.currentPatient)!.fullName}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: ShadcnColors.accent700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Age: ${(_selectedPatient ?? PatientManager.currentPatient)!.age} years • ${(_selectedPatient ?? PatientManager.currentPatient)!.gender}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: ShadcnColors.accent600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Blood Group: ${(_selectedPatient ?? PatientManager.currentPatient)!.bloodGroup} • CNIC: ${(_selectedPatient ?? PatientManager.currentPatient)!.cnic}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: ShadcnColors.accent600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Phone: ${(_selectedPatient ?? PatientManager.currentPatient)!.contactNumber}',
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
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          // Previous Vitals History
                          if (_patientVitalsHistory.isNotEmpty) ...[
                            Text(
                              'Previous Vitals (${_patientVitalsHistory.length} records)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...(_patientVitalsHistory.take(3).map((record) => 
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: _buildVitalsDisplayForHistory(record),
                              ),
                            ).toList()),
                            if (_patientVitalsHistory.length > 3)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade700,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_patientVitalsHistory.length - 3} more records available',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
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
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 16),
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
                                decoration: const InputDecoration(
                                  labelText: 'Weight (kg) *',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => _rangeValidator(value, 1, 220, 'Weight'),
                                onFieldSubmitted: (value) => _onFieldSubmitted(_weightController, 1, 220, 'Weight'),
                                onChanged: (value) => setState(() {}),
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
                                decoration: const InputDecoration(
                                  labelText: 'Height (cm) *',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => _rangeValidator(value, 50, 250, 'Height'),
                                onFieldSubmitted: (value) => _onFieldSubmitted(_heightController, 50, 250, 'Height'),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Save/Cancel buttons - fixed width and right-aligned
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              SizedBox(
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
        return ShadcnColors.success;
      case VitalSeverity.warning:
        return ShadcnColors.warning;
      case VitalSeverity.critical:
        return ShadcnColors.destructive;
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

