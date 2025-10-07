import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'doctor_dashboard.dart';
import 'receptionist_dashboard.dart';
import 'patient_selection_page.dart';
import '../models/user_type.dart';
import '../theme/theme_controller.dart';
import '../services/auth_service.dart';
import '../widgets/animated_popup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  UserType _selectedUserType = UserType.doctor;

  // Responsive sizing methods
  double getResponsiveSize(double baseSize) {
    final screenSize = MediaQuery.of(context).size;
    final scaleFactor = screenSize.width < 600 ? 0.315 : screenSize.width < 1200 ? 0.64 : 1.0;
    return baseSize * scaleFactor;
  }

  double getResponsiveHeight(double baseHeight) {
    final screenSize = MediaQuery.of(context).size;
    final scaleFactor = screenSize.height < 800 ? 0.3675 : screenSize.height < 1000 ? 0.72 : 1.0;
    return baseHeight * scaleFactor;
  }

  double getResponsiveFontSize(double baseFontSize) {
    final screenSize = MediaQuery.of(context).size;
    final scaleFactor = screenSize.width < 600 ? 0.3675 : screenSize.width < 1200 ? 0.72 : 1.0;
    return baseFontSize * scaleFactor;
  }

  @override
  void dispose() {
    _cnicController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // For receptionist, use the old flow (bypass authentication)
      if (_selectedUserType == UserType.receptionist) {
        if (kDebugMode) {
          print('🔍 Bypassing authentication for receptionist - using old flow');
        }
        
        // Show success popup
        PopupHelper.showSuccess(
          context,
          'Welcome back, Receptionist!',
        );
        
        // Navigate after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ReceptionistDashboard(),
            ),
          );
        }
        return;
      }

      // For doctor, use API authentication
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.login(
          _cnicController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response.success && response.data != null) {
          final userData = response.data!['user'] as Map<String, dynamic>?;
          final roles = userData?['roles'] as List<dynamic>?;
          
          // Debug logging
          if (kDebugMode) {
            print('🔍 User roles: $roles');
            print('🔍 Selected user type: ${_selectedUserType.name}');
          }
          
          // Check if user has the selected role
          final expectedRole = _selectedUserType == UserType.doctor ? 'Doctor' : 'Receptionist';
          if (kDebugMode) {
            print('🔍 Expected role: $expectedRole');
            print('🔍 Role check result: ${roles?.contains(expectedRole)}');
          }
          
          if (roles != null && roles.contains(expectedRole)) {
            // Show success popup
            PopupHelper.showSuccess(
              context,
              'Welcome back, ${userData?['name'] ?? 'Doctor'}!',
            );
            
            // Navigate after a short delay
            await Future.delayed(const Duration(milliseconds: 1500));
            
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PatientSelectionPage(userType: _selectedUserType),
                ),
              );
            }
          } else {
            // User doesn't have the selected role
            PopupHelper.showError(
              context,
              'Access denied. You don\'t have $expectedRole privileges.',
            );
          }
        } else {
          // Login failed
          PopupHelper.showError(
            context,
            response.message,
          );
        }
      } catch (e) {
        PopupHelper.showError(
          context,
          'An unexpected error occurred. Please try again.',
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ThemeController.instance.useShadcn.value
                ? [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ]
                : [
                    Colors.green.shade300.withOpacity(0.25),
                    Colors.green.shade100.withOpacity(0.15),
                  ],
          ),
        ),
        child: Row(
          children: <Widget>[
            // Left side - Branding section
            Container(
              width: screenSize.width * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: ThemeController.instance.useShadcn.value
                      ? [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                          theme.colorScheme.secondary,
                        ]
                      : [
                          Colors.green.shade600,
                          Colors.green.shade500,
                          Colors.green.shade400,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: getResponsiveSize(24),
                    right: getResponsiveSize(24),
                    top: getResponsiveSize(24),
                    bottom: getResponsiveSize(24),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: EdgeInsets.all(getResponsiveSize(40)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Logo area with enhanced styling
                          SizedBox(
                            height: getResponsiveHeight(120),
                            child: Image.asset(
                              'assets/images/punjab.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.local_hospital_rounded,
                                  size: getResponsiveSize(80),
                                  color: Colors.white.withOpacity(0.9),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: getResponsiveSize(32)),
                          // Welcome text with enhanced typography
                          Text(
                            'Welcome back',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: getResponsiveFontSize(32),
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: getResponsiveSize(16)),
                          Text(
                            'Sign in to your account',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                              fontSize: getResponsiveFontSize(18),
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: getResponsiveSize(40)),
                          // Feature highlights
                          Container(
                            padding: EdgeInsets.all(getResponsiveSize(24)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(getResponsiveSize(16)),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildFeatureItem(
                                  Icons.security_rounded,
                                  'Secure Access',
                                  'Your data is protected with enterprise-grade security',
                                  Colors.white.withOpacity(0.9),
                                  getResponsiveSize(16),
                                ),
                                SizedBox(height: getResponsiveSize(16)),
                                _buildFeatureItem(
                                  Icons.medical_services_rounded,
                                  'Healthcare Management',
                                  'Comprehensive patient and family management system',
                                  Colors.white.withOpacity(0.9),
                                  getResponsiveSize(16),
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
            ),
            // Right side - Login form
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(
                      left: getResponsiveSize(24),
                      right: getResponsiveSize(24),
                      top: getResponsiveSize(24),
                      bottom: MediaQuery.of(context).viewInsets.bottom + getResponsiveSize(24),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: getResponsiveSize(450)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Header
                            Text(
                              'Sign In',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: getResponsiveFontSize(28),
                                color: theme.colorScheme.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: getResponsiveSize(8)),
                            Text(
                              'Enter your credentials to access your account',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                                fontSize: getResponsiveFontSize(16),
                              ),
                            ),
                            SizedBox(height: getResponsiveSize(40)),
                            // User type selection tabs
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                              ),
                              child: Row(
                                children: UserType.values.map((userType) {
                                  final isSelected = _selectedUserType == userType;
                                  return Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedUserType = userType;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: getResponsiveSize(16),
                                          horizontal: getResponsiveSize(8),
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              userType.icon,
                                              style: TextStyle(fontSize: getResponsiveSize(24)),
                                            ),
                                            SizedBox(height: getResponsiveSize(4)),
                                            Text(
                                              userType.displayName,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                fontSize: getResponsiveFontSize(14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: getResponsiveSize(24)),
                            // CNIC field with enhanced styling
                            TextFormField(
                              controller: _cnicController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'CNIC',
                                hintText: '12345-1234567-1',
                                prefixIcon: Icon(
                                  Icons.credit_card_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: getResponsiveSize(2),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: getResponsiveSize(16),
                                  vertical: getResponsiveSize(16),
                                ),
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
                            SizedBox(height: getResponsiveSize(24)),
                            // Password field with enhanced styling
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: getResponsiveSize(2),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: getResponsiveSize(16),
                                  vertical: getResponsiveSize(16),
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
                            SizedBox(height: getResponsiveSize(32)),
                            // Enhanced login button
                            Container(
                              height: getResponsiveSize(56),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: getResponsiveSize(8),
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: FilledButton(
                                onPressed: _isLoading ? null : _login,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(getResponsiveSize(12)),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: getResponsiveSize(20),
                                        height: getResponsiveSize(20),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: getResponsiveFontSize(16),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: getResponsiveSize(24)),
                            // Sample credentials for testing (only in debug mode)
                            if (kDebugMode) ...[
                              Container(
                                padding: EdgeInsets.all(getResponsiveSize(16)),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(getResponsiveSize(8)),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedUserType == UserType.doctor 
                                          ? 'Sample Doctor Credentials (Debug)'
                                          : 'Receptionist Login (Debug)',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                        fontSize: getResponsiveFontSize(14),
                                      ),
                                    ),
                                    SizedBox(height: getResponsiveSize(8)),
                                    Text(
                                      _selectedUserType == UserType.doctor
                                          ? 'CNIC: 12345-1234567-1\nPassword: Doctor123!'
                                          : 'Any CNIC and password will work\n(No API authentication required)',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.blue.shade700,
                                        fontSize: getResponsiveFontSize(12),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    SizedBox(height: getResponsiveSize(8)),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: _isLoading ? null : () {
                                          if (_selectedUserType == UserType.doctor) {
                                            _cnicController.text = '12345-1234567-1';
                                            _passwordController.text = 'Doctor123!';
                                          } else {
                                            _cnicController.text = '12345-1234567-1';
                                            _passwordController.text = 'password123';
                                          }
                                        },
                                        icon: const Icon(Icons.person_add, size: 16),
                                        label: Text(_selectedUserType == UserType.doctor 
                                            ? 'Use Sample Doctor Credentials'
                                            : 'Use Sample Receptionist Credentials'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.blue.shade700,
                                          side: BorderSide(color: Colors.blue.shade300),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: getResponsiveSize(16)),
                            ],
                            // Footer text
                            Text(
                              'By signing in, you agree to our Terms of Service and Privacy Policy',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: getResponsiveFontSize(12),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color, double spacing) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(getResponsiveSize(8)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(getResponsiveSize(8)),
          ),
          child: Icon(icon, color: color, size: getResponsiveSize(20)),
        ),
        SizedBox(width: getResponsiveSize(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: getResponsiveFontSize(14),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: getResponsiveFontSize(12),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
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
