import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'doctor_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _cnicController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigate to doctor dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DoctorDashboard(),
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

    return Scaffold(
      body: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
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
                            'Welcome back',
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
                            'Sign in to your account',
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // Login form fields
                              TextFormField(
                                controller: _cnicController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'CNIC',
                                  hintText: '12345-1234567-1',
                                  border: OutlineInputBorder(),
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
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
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
                              const SizedBox(height: 24),
                              // Login button
                              SizedBox(
                                height: 56,
                                child: FilledButton(
                                  onPressed: _login,
                                  style: FilledButton.styleFrom(
                                    textStyle: theme.textTheme.titleMedium,
                                  ),
                                  child: const Text('Sign in'),
                                ),
                              ),
                            ],
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
    final String formatted = _LoginPageState._formatCnic(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
