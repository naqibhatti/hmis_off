import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/patient_data.dart';
import '../theme/shadcn_colors.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  DateTime? _dateOfBirth;
  String? _gender; // 'Male' or 'Female'
  String? _emergencyRelation; // dropdown
  String? _bloodGroup; // dropdown
  String? _registrationType; // 'Self' or 'Others'
  String? _parentType; // 'Father' or 'Mother'

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactNameController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_registrationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select registration type (Self or Others)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      // Calculate age from date of birth
      int age = 0;
      if (_dateOfBirth != null) {
        final now = DateTime.now();
        age = now.year - _dateOfBirth!.year;
        if (now.month < _dateOfBirth!.month || 
            (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
          age--;
        }
      }

      // Create patient data
      final patient = PatientData(
        fullName: _fullNameController.text.trim(),
        age: age,
        bloodGroup: _bloodGroup ?? '',
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        cnic: _cnicController.text.trim(),
        gender: _gender ?? '',
        dateOfBirth: _dateOfBirth ?? DateTime.now(),
      );

      // Save patient data
      PatientManager.setPatient(patient);

      // Show success dialog and return to dashboard
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Patient Registration'),
          content: Text('Patient "${patient.fullName}" registered successfully for $_registrationType registration.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to dashboard
              },
              child: const Text('OK'),
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

  String _getCnicLabel() {
    if (_registrationType == 'Others') {
      if (_parentType == 'Father') {
        return 'Father\'s CNIC';
      } else if (_parentType == 'Mother') {
        return 'Mother\'s CNIC';
      } else {
        return 'Parent\'s CNIC';
      }
    }
    return 'CNIC';
  }

  // Formats numeric input into 12345-1234567-1 as the user types.
  static final RegExp _nonDigit = RegExp(r'[^0-9]');
  static String _formatCnic(String raw) {
    final String digits = raw.replaceAll(_nonDigit, '');
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      out.write(digits[i]);
      if (i == 4 || i == 11) {
        if (i != digits.length - 1) out.write('-');
      }
    }
    return out.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
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
                      // Registration type radio buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Register as:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Self'),
                                    value: 'Self',
                                    groupValue: _registrationType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _registrationType = value;
                                        if (value == 'Self') {
                                          _parentType = null; // Reset parent type when Self is selected
                                        }
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Others'),
                                    value: 'Others',
                                    groupValue: _registrationType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _registrationType = value;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            // Parent type dropdown (only show when Others is selected)
                            if (_registrationType == 'Others') ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _parentType,
                                decoration: const InputDecoration(
                                  labelText: 'Parent Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: const <String>[
                                  'Father', 'Mother'
                                ].map((p) => DropdownMenuItem<String>(value: p, child: Text(p))).toList(),
                                onChanged: (value) => setState(() => _parentType = value),
                                validator: (v) => v == null || v.isEmpty ? 'Select parent type' : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _fullNameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => _requiredValidator(v, fieldName: 'Full name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cnicController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: _getCnicLabel(),
                                hintText: '12345-1234567-1',
                                border: const OutlineInputBorder(),
                              ),
                              inputFormatters: <TextInputFormatter>[
                                _CnicInputFormatter(),
                              ],
                              validator: (value) {
                                final String? requiredResult = _requiredValidator(value, fieldName: 'CNIC');
                                if (requiredResult != null) return requiredResult;
                                final RegExp pattern = RegExp(r'^\d{5}-\d{7}-\d{1}$');
                                if (!pattern.hasMatch(value!.trim())) {
                                  return 'Enter CNIC as 12345-1234567-1';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final DateTime now = DateTime.now();
                                final DateTime first = DateTime(now.year - 120);
                                final DateTime last = now;
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dateOfBirth ?? DateTime(now.year - 30, 1, 1),
                                  firstDate: first,
                                  lastDate: last,
                                );
                                if (picked != null) {
                                  setState(() {
                                    _dateOfBirth = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of birth',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _dateOfBirth == null
                                      ? 'Select date'
                                      : '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Gender'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  children: <Widget>[
                                    ChoiceChip(
                                      label: const Text('Male'),
                                      selected: _gender == 'Male',
                                      onSelected: (selected) {
                                        setState(() => _gender = selected ? 'Male' : null);
                                      },
                                    ),
                                    ChoiceChip(
                                      label: const Text('Female'),
                                      selected: _gender == 'Female',
                                      onSelected: (selected) {
                                        setState(() => _gender = selected ? 'Female' : null);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final String? requiredResult = _requiredValidator(value, fieldName: 'Email');
                                if (requiredResult != null) return requiredResult;
                                final String trimmed = value!.trim();
                                final bool looksValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
                                if (!looksValid) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                                hintText: '0300-1234567',
                              ),
                              validator: (value) {
                                final String? requiredResult = _requiredValidator(value, fieldName: 'Phone');
                                if (requiredResult != null) return requiredResult;
                                final String digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
                                if (digits.length < 7) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: _addressController,
                                keyboardType: TextInputType.streetAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _requiredValidator(v, fieldName: 'Address'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(), // Empty container to maintain spacing
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _bloodGroup,
                                decoration: const InputDecoration(
                                  labelText: 'Blood group',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                                ].map((g) => DropdownMenuItem<String>(value: g, child: Text(g))).toList(),
                                onChanged: (value) => setState(() => _bloodGroup = value),
                                validator: (v) => v == null || v.isEmpty ? 'Select blood group' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(), // Empty container to maintain spacing
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyContactNameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Emergency contact name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => _requiredValidator(v, fieldName: 'Emergency contact name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _emergencyRelation,
                              decoration: const InputDecoration(
                                labelText: 'Emergency contact relation',
                                border: OutlineInputBorder(),
                              ),
                              items: const <String>[
                                'Parent', 'Spouse', 'Child', 'Sibling', 'Relative', 'Friend', 'Guardian'
                              ].map((r) => DropdownMenuItem<String>(value: r, child: Text(r))).toList(),
                              onChanged: (value) => setState(() => _emergencyRelation = value),
                              validator: (v) => v == null || v.isEmpty ? 'Select relation' : null,
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
                            child: const Text('Save Patient'),
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

class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String formatted = _AddPatientPageState._formatCnic(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
