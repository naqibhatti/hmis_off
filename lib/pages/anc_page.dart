import 'package:flutter/material.dart';
import '../models/patient_data.dart';
import '../services/patient_data_service.dart';
import '../theme/shadcn_colors.dart';
import '../widgets/side_navigation_drawer.dart';
import '../widgets/square_tab.dart';
import '../theme/theme_controller.dart';
import 'patient_selection_page.dart';
import '../models/user_type.dart';

class AncPage extends StatefulWidget {
  const AncPage({super.key});

  @override
  State<AncPage> createState() => _AncPageState();
}

class _AncPageState extends State<AncPage> with TickerProviderStateMixin {
  late VoidCallback _patientListener;
  late TabController _tabController;
  
  // Form controllers
  final TextEditingController _lmpController = TextEditingController();
  final TextEditingController _gravidaController = TextEditingController();
  final TextEditingController _paraController = TextEditingController();
  final TextEditingController _abortionController = TextEditingController();
  final TextEditingController _gestationAgeController = TextEditingController();
  final TextEditingController _eddController = TextEditingController();
  final TextEditingController _trimesterController = TextEditingController();
  final TextEditingController _birthAddressController = TextEditingController();
  final TextEditingController _husbandNameController = TextEditingController();
  final TextEditingController _husbandCnicController = TextEditingController();
  
  // Tab progression state
  List<bool> _tabCompleted = [true, false, false, false, false, false]; // First tab enabled by default
  int _currentTabIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: 0);
    _patientListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    PatientManager.addListener(_patientListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lmpController.dispose();
    _gravidaController.dispose();
    _paraController.dispose();
    _abortionController.dispose();
    _gestationAgeController.dispose();
    _eddController.dispose();
    _trimesterController.dispose();
    _birthAddressController.dispose();
    _husbandNameController.dispose();
    _husbandCnicController.dispose();
    PatientManager.removeListener(_patientListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ThemeController.instance.useShadcn.value
          ? Colors.grey.shade50
          : Colors.green.shade50,
      body: SideNavigationDrawer(
        currentRoute: '/anc-page',
        userType: 'Doctor',
        child: Column(
          children: <Widget>[
            // Selected patient (compact)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (_) {
                    final p = PatientManager.currentPatient;
                    if (p == null) {
                      return Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('No patient selected. Tap the change icon to select a patient.'),
                          ),
                          IconButton(
                            tooltip: 'Change patient',
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const PatientSelectionPage(userType: UserType.doctor),
                                ),
                              );
                            },
                            icon: const Icon(Icons.swap_horiz),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: ShadcnColors.accent100,
                          child: Text(
                            p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                            style: TextStyle(color: ShadcnColors.accent700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${p.fullName} • ${p.age}y • ${p.gender} • ${p.cnic}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Change patient',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const PatientSelectionPage(userType: UserType.doctor),
                              ),
                            );
                          },
                          icon: const Icon(Icons.swap_horiz),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Tab Bar
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: ThemeController.instance.useShadcn.value
                        ? [
                            Colors.grey.shade50,
                            Colors.white,
                          ]
                        : [
                            Colors.green.shade100,
                            Colors.white,
                          ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                   child: SquareTabWidget(
                     tabs: const [
                       'Pregnancy Info',
                       'Medical History',
                       'Vitals',
                       'Ultrasound',
                       'Supplements',
                       'Referrals',
                     ],
                     children: [
                       _buildPregnancyInfoTab(),
                       _buildMedicalHistoryTab(),
                       _buildVitalsTab(),
                       _buildUltrasoundTab(),
                       _buildSupplementsTab(),
                       _buildReferralsTab(),
                     ],
                     controller: _tabController,
                     initialIndex: _currentTabIndex,
                     tabEnabled: _tabCompleted,
                     onTabChanged: (index) {
                       setState(() {
                         _currentTabIndex = index;
                       });
                     },
                   ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyInfoTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent200
                    : Colors.green.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Menstrual Period',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectLMPDate(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _lmpController.text.isEmpty ? 'Select LMP Date' : _lmpController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _lmpController.text.isEmpty ? Colors.grey.shade500 : Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement LMP edit functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit LMP',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Form Fields
          Text(
            'Pregnancy Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          // First Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Gravida',
                  controller: _gravidaController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Para',
                  controller: _paraController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Abortion',
                  controller: _abortionController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Gestation Age',
                  controller: _gestationAgeController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'Estimated date of delivery',
                  controller: _eddController,
                  onTap: () => _selectEDDDate(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Trimester',
                  controller: _trimesterController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Third Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Birth Address',
                  controller: _birthAddressController,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Husband Name',
                  controller: _husbandNameController,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Husband CNIC',
                  controller: _husbandCnicController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetPregnancyInfoFields();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeController.instance.useShadcn.value
                        ? ShadcnColors.accent700
                        : Colors.green.shade700,
                    side: BorderSide(
                      color: ThemeController.instance.useShadcn.value
                          ? ShadcnColors.accent300
                          : Colors.green.shade300,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _saveAndContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeController.instance.useShadcn.value
                        ? ShadcnColors.accent
                        : Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save and Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: _getHintText(label),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Select ${label.toLowerCase()}' : controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: controller.text.isEmpty ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectLMPDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // Only past dates allowed
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent
                  : Colors.green.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _lmpController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectEDDDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 280)), // ~9 months from now
      firstDate: DateTime.now().add(const Duration(days: 1)), // Only future dates allowed (tomorrow onwards)
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years from now
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent
                  : Colors.green.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eddController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _getHintText(String label) {
    switch (label) {
      case 'Gravida':
        return 'e.g., 1, 2, 3...';
      case 'Para':
        return 'e.g., 0, 1, 2...';
      case 'Abortion':
        return 'e.g., 0, 1, 2...';
      case 'Gestation Age':
        return 'e.g., 20, 25, 30 weeks';
      case 'Trimester':
        return 'e.g., First, Second, Third';
      case 'Birth Address':
        return 'e.g., Gulshan-e-Iqbal, Karachi';
      case 'Husband Name':
        return 'e.g., Muhammad Ali';
      case 'Husband CNIC':
        return 'e.g., 12345-1234567-1';
      default:
        return '';
    }
  }

  void _resetPregnancyInfoFields() {
    setState(() {
      _lmpController.clear();
      _gravidaController.clear();
      _paraController.clear();
      _abortionController.clear();
      _gestationAgeController.clear();
      _eddController.clear();
      _trimesterController.clear();
      _birthAddressController.clear();
      _husbandNameController.clear();
      _husbandCnicController.clear();
    });
  }

  void _saveAndContinue() {
    // Validate required fields
    if (!_validatePregnancyInfoFields()) {
      return; // Stop if validation fails
    }
    
    // Mark current tab as completed
    setState(() {
      _tabCompleted[_currentTabIndex] = true;
      
      // Move to next tab if available
      if (_currentTabIndex < _tabCompleted.length - 1) {
        _currentTabIndex = _currentTabIndex + 1;
        // Enable the next tab before switching
        _tabCompleted[_currentTabIndex] = true;
        // Programmatically switch to the next tab
        _tabController.animateTo(_currentTabIndex);
      }
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pregnancy Info saved successfully! Moving to ${_getNextTabName()}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _validatePregnancyInfoFields() {
    // Check if LMP is selected
    if (_lmpController.text.isEmpty) {
      _showValidationError('Please select Last Menstrual Period');
      return false;
    }
    
    // Check required fields
    if (_gravidaController.text.isEmpty) {
      _showValidationError('Please enter Gravida');
      return false;
    }
    
    if (_paraController.text.isEmpty) {
      _showValidationError('Please enter Para');
      return false;
    }
    
    if (_abortionController.text.isEmpty) {
      _showValidationError('Please enter Abortion');
      return false;
    }
    
    if (_birthAddressController.text.isEmpty) {
      _showValidationError('Please enter Birth Address');
      return false;
    }
    
    if (_husbandNameController.text.isEmpty) {
      _showValidationError('Please enter Husband Name');
      return false;
    }
    
    if (_husbandCnicController.text.isEmpty) {
      _showValidationError('Please enter Husband CNIC');
      return false;
    }
    
    // Validate numeric fields
    if (!_isValidNumber(_gravidaController.text)) {
      _showValidationError('Gravida must be a valid number');
      return false;
    }
    
    if (!_isValidNumber(_paraController.text)) {
      _showValidationError('Para must be a valid number');
      return false;
    }
    
    if (!_isValidNumber(_abortionController.text)) {
      _showValidationError('Abortion must be a valid number');
      return false;
    }
    
    if (_gestationAgeController.text.isNotEmpty && !_isValidNumber(_gestationAgeController.text)) {
      _showValidationError('Gestation Age must be a valid number');
      return false;
    }
    
    // Validate CNIC format (basic validation)
    if (!_isValidCNIC(_husbandCnicController.text)) {
      _showValidationError('Please enter a valid CNIC format (e.g., 12345-1234567-1)');
      return false;
    }
    
    return true;
  }

  bool _isValidNumber(String value) {
    if (value.isEmpty) return false;
    final number = int.tryParse(value);
    return number != null && number >= 0;
  }

  bool _isValidCNIC(String cnic) {
    if (cnic.isEmpty) return false;
    // Basic CNIC format validation: 12345-1234567-1
    final RegExp cnicPattern = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    return cnicPattern.hasMatch(cnic);
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getNextTabName() {
    const tabNames = ['Pregnancy Info', 'Medical History', 'Vitals', 'Ultrasound', 'Supplements', 'Referrals'];
    final nextIndex = _currentTabIndex + 1;
    if (nextIndex < tabNames.length) {
      return tabNames[nextIndex];
    }
    return 'next tab';
  }

  Widget _buildMedicalHistoryTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'Medical History Tab\n\nThis section will contain:\n• Previous Medical Conditions\n• Family History\n• Allergies\n• Current Medications\n• Previous Surgeries',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildVitalsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'Vitals Tab\n\nThis section will contain:\n• Blood Pressure\n• Weight\n• Height\n• BMI\n• Heart Rate\n• Temperature',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildUltrasoundTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'Ultrasound Tab\n\nThis section will contain:\n• Ultrasound Reports\n• Fetal Measurements\n• Growth Charts\n• Images\n• Reports History',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSupplementsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'Supplements Tab\n\nThis section will contain:\n• Folic Acid\n• Iron Supplements\n• Calcium\n• Vitamin D\n• Prescription History\n• Dosage Tracking',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildReferralsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'Referrals Tab\n\nThis section will contain:\n• Specialist Referrals\n• Hospital Referrals\n• Emergency Contacts\n• Referral History\n• Follow-up Appointments',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

}
