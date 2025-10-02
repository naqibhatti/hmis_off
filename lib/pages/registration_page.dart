import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  DateTime? _dateOfBirth;
  String? _gender; // 'Male' or 'Female'
  String? _emergencyRelation; // dropdown
  String? _bloodGroup; // dropdown
  String? _registrationType; // 'Self' or 'Others'

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactNameController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      // For now, just show a dialog. Will integrate backend later.
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration'),
          content: Text('Form submitted successfully for $_registrationType registration.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
    final double deviceWidth = MediaQuery.of(context).size.width;
    double formScale = 1.0;
    if (deviceWidth < 600) {
      formScale = 0.5; // mobile
    } else if (deviceWidth < 1024) {
      formScale = 0.8; // tablet
    }

    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: theme.colorScheme.primary,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Logo area
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 140,
                            child: Image.asset(
                              'assets/images/punjab.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.local_hospital,
                                  size: 96,
                                  color: theme.colorScheme.onPrimary.withOpacity(0.85),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Create your account',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: ((theme.textTheme.displaySmall?.fontSize) ?? 36) * 1.02,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Register as a patient',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxFormWidth = 800;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxFormWidth),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Transform.scale(
                            scale: formScale,
                            alignment: Alignment.topCenter,
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
                                        labelText: _registrationType == 'Others' ? 'Father\'s CNIC' : 'CNIC',
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
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      validator: (value) {
                                        final String? requiredResult = _requiredValidator(value, fieldName: 'Password');
                                        if (requiredResult != null) return requiredResult;
                                        if (value!.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                        labelText: 'Confirm password',
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                        ),
                                      ),
                                      validator: (value) {
                                        final String? requiredResult = _requiredValidator(value, fieldName: 'Confirm password');
                                        if (requiredResult != null) return requiredResult;
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 56,
                                child: FilledButton(
                                  onPressed: _submit,
                                  style: FilledButton.styleFrom(
                                    textStyle: theme.textTheme.titleMedium,
                                  ),
                                  child: const Text('Create account'),
                                ),
                              ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
    final String formatted = _RegistrationPageState._formatCnic(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


