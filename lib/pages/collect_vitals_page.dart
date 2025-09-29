import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import 'vitals_pdf_preview_page.dart';
import '../models/patient_data.dart';
import '../services/patient_data_service.dart';
import '../services/vitals_storage_service.dart';

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
                 patient.phone.contains(query);
        }).toList();
      }
    });
  }

  void _submit() {
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

  // Build vitals history card
  Widget _buildVitalsHistoryCard(VitalsRecord record) {
    final theme = Theme.of(context);
    final isRecent = DateTime.now().difference(record.recordedAt).inDays < 7;
    
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRecent ? Colors.green.shade300 : Colors.grey.shade300,
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
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: isRecent ? Colors.green.shade600 : Colors.grey.shade600,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child:           Text(
            _formatDate(record.recordedAt),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isRecent ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVitalRow('BP', '${record.systolic}/${record.diastolic}', 'systolic', record.systolic.toString()),
          _buildVitalRow('Weight', '${record.weight}kg', 'weight', record.weight.toString()),
          if (record.temperature != null)
            _buildVitalRow('Temp', '${record.temperature}°F', 'temperature', record.temperature.toString()),
          if (record.pulse != null)
            _buildVitalRow('Pulse', '${record.pulse}bpm', 'pulse', record.pulse.toString()),
          _buildVitalRow('Height', '${record.height}cm', 'height', record.height.toString()),
          const SizedBox(height: 8),
          Text(
            'By: ${record.recordedBy}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Build individual vital row in history card
  Widget _buildVitalRow(String label, String value, String vitalType, String valueString) {
    final color = _getVitalColor(vitalType, valueString);
    final isAbnormal = _isVitalAbnormal(vitalType, valueString);
    
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
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Patient Selection Dropdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_search,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Select Patient',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Autocomplete<PatientData>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return _allPatients.take(10);
                                }
                                return _filteredPatients.take(10);
                              },
                              displayStringForOption: (PatientData patient) => 
                                  '${patient.fullName} (${patient.cnic}) - ${patient.age} years',
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                _patientSearchController.addListener(() {
                                  controller.text = _patientSearchController.text;
                                });
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Search by name, CNIC, or phone...',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _selectedPatient != null
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {
                                                _selectedPatient = null;
                                                _patientSearchController.clear();
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                  onChanged: (value) {
                                    _patientSearchController.text = value;
                                  },
                                );
                              },
                              onSelected: (PatientData patient) {
                                setState(() {
                                  _selectedPatient = patient;
                                  _patientSearchController.text = '${patient.fullName} (${patient.cnic})';
                                  _loadPatientVitals();
                                });
                              },
                              optionsViewBuilder: (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4.0,
                                    borderRadius: BorderRadius.circular(8),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxHeight: 200),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          final patient = options.elementAt(index);
                                          return ListTile(
                                            dense: true,
                                            leading: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.blue.shade100,
                                              child: Text(
                                                patient.fullName[0].toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              patient.fullName,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              '${patient.cnic} • ${patient.age} years • ${patient.bloodGroup}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            onTap: () => onSelected(patient),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Patient Information Card
                      if (_selectedPatient != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  _selectedPatient!.fullName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.green.shade700,
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
                                      'Patient: ${_selectedPatient!.fullName}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Age: ${_selectedPatient!.age} years • ${_selectedPatient!.gender}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Blood Group: ${_selectedPatient!.bloodGroup} • CNIC: ${_selectedPatient!.cnic}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Phone: ${_selectedPatient!.phone}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Previous Vitals History
                        if (_patientVitalsHistory.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      color: Colors.orange.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Previous Vitals (${_patientVitalsHistory.length} records)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _patientVitalsHistory.length,
                                    itemBuilder: (context, index) {
                                      final record = _patientVitalsHistory[index];
                                      return _buildVitalsHistoryCard(record);
                                    },
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
                      const SizedBox(height: 16),
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

