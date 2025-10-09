import 'package:flutter/material.dart';
import '../models/patient_data.dart';
import '../services/patient_data_service.dart';
import '../theme/shadcn_colors.dart';
import '../widgets/side_navigation_drawer.dart';
import '../widgets/square_tab.dart';
import '../theme/theme_controller.dart';
import 'patient_selection_page.dart';
import 'pregnancy_dashboard.dart';
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
  
  // Medical History controllers
  final TextEditingController _previousIllnessController = TextEditingController();
  final TextEditingController _pastObstetricHistoryController = TextEditingController();
  
  // Selected medical conditions
  List<String> _selectedConditions = [];
  
  // Selected obstetric history conditions
  List<String> _selectedObstetricHistory = [];
  
  // Vitals controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _weightGainController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _hbController = TextEditingController();
  final TextEditingController _fundalHeightController = TextEditingController();
  final TextEditingController _bsrController = TextEditingController();
  final TextEditingController _albuminController = TextEditingController();
  final TextEditingController _muacController = TextEditingController();
  final TextEditingController _dangerSignsController = TextEditingController();
  
  // Blood group dropdown value
  String? _selectedBloodGroup;
  
  // Ultrasound section
  bool _ultrasoundConducted = false;
  
  // Ultrasound form controllers
  String? _selectedTypeOfPregnancy;
  String? _selectedFetalMovement;
  String? _selectedPresentation;
  String? _selectedDeliveryType;
  String? _selectedPlacenta;
  String? _selectedPlacentaCondition;
  String? _selectedLiquor;
  final TextEditingController _fetalHeartRateController = TextEditingController();
  
  // Supplements section
  bool _supplementsGiven = false;
  List<Map<String, dynamic>> _selectedSupplements = [];
  
  // Referrals section
  bool _patientReferred = false;
  String? _selectedDistrict;
  String? _selectedType;
  String? _selectedHealthFacility;
  
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
    _previousIllnessController.dispose();
    _pastObstetricHistoryController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _weightGainController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _temperatureController.dispose();
    _bloodGroupController.dispose();
    _hbController.dispose();
    _fundalHeightController.dispose();
    _bsrController.dispose();
    _albuminController.dispose();
    _muacController.dispose();
    _dangerSignsController.dispose();
    _fetalHeartRateController.dispose();
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
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox.shrink(),
              ),
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

  void _resetMedicalHistoryFields() {
    setState(() {
      _previousIllnessController.clear();
      _pastObstetricHistoryController.clear();
      _selectedConditions.clear();
      _selectedObstetricHistory.clear();
    });
  }

  void _resetVitalsFields() {
    setState(() {
      _heightController.clear();
      _weightController.clear();
      _bmiController.clear();
      _weightGainController.clear();
      _systolicController.clear();
      _diastolicController.clear();
      _temperatureController.clear();
      _selectedBloodGroup = null;
      _hbController.clear();
      _fundalHeightController.clear();
      _bsrController.clear();
      _albuminController.clear();
      _muacController.clear();
      _dangerSignsController.clear();
    });
  }

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    
    if (height != null && weight != null && height > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      _bmiController.text = bmi.toStringAsFixed(2);
    }
  }

  void _saveAndContinueVitals() {
    // Validation disabled for testing purposes

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
        content: Text('Vitals saved successfully! Moving to ${_getNextTabName()}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetUltrasoundFields() {
    setState(() {
      _ultrasoundConducted = false;
      _selectedTypeOfPregnancy = null;
      _selectedFetalMovement = null;
      _selectedPresentation = null;
      _selectedDeliveryType = null;
      _selectedPlacenta = null;
      _selectedPlacentaCondition = null;
      _selectedLiquor = null;
      _fetalHeartRateController.clear();
    });
  }

  void _resetSupplementsFields() {
    setState(() {
      _supplementsGiven = false;
      _selectedSupplements.clear();
    });
  }

  void _resetReferralsFields() {
    setState(() {
      _patientReferred = false;
      _selectedDistrict = null;
      _selectedType = null;
      _selectedHealthFacility = null;
    });
  }

  void _saveAndContinueUltrasound() {
    // Validation disabled for testing purposes

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
        content: Text('Ultrasound data saved successfully! Moving to ${_getNextTabName()}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveAndContinueSupplements() {
    // Validation disabled for testing purposes
    
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
        content: Text('Supplements data saved successfully! Moving to ${_getNextTabName()}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSupplementsModal() {
    final List<Map<String, dynamic>> availableSupplements = [
      {'name': 'Calcium supplements', 'quantity': 1},
      {'name': 'Iron supplements', 'quantity': 1},
      {'name': 'Folic acid', 'quantity': 1},
      {'name': 'Vitamin D', 'quantity': 1},
      {'name': 'Multivitamin', 'quantity': 1},
      {'name': 'Omega-3', 'quantity': 1},
      {'name': 'Magnesium', 'quantity': 1},
      {'name': 'Zinc', 'quantity': 1},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Supplements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeController.instance.useShadcn.value
                            ? ShadcnColors.accent700
                            : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableSupplements.length,
                        itemBuilder: (context, index) {
                          final supplement = availableSupplements[index];
                          final isSelected = _selectedSupplements.any(
                            (selected) => selected['name'] == supplement['name'],
                          );
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(supplement['name']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setModalState(() {
                                          _selectedSupplements.removeWhere(
                                            (selected) => selected['name'] == supplement['name'],
                                          );
                                        });
                                      },
                                    ),
                                    Text('${_selectedSupplements.firstWhere((s) => s['name'] == supplement['name'])['quantity']}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setModalState(() {
                                          final index = _selectedSupplements.indexWhere(
                                            (selected) => selected['name'] == supplement['name'],
                                          );
                                          if (index != -1) {
                                            _selectedSupplements[index]['quantity']++;
                                          }
                                        });
                                      },
                                    ),
                                  ] else
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setModalState(() {
                                          _selectedSupplements.add({
                                            'name': supplement['name'],
                                            'quantity': 1,
                                          });
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent
                                : Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveAndContinueReferrals() {
    // Validation disabled for testing purposes
    
    // Mark current tab as completed
    setState(() {
      _tabCompleted[_currentTabIndex] = true;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referrals data saved successfully! Returning to Pregnancy Dashboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Navigate back to Pregnancy Dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PregnancyDashboard(),
      ),
    );
  }

  Color _getFieldColor(String value, double minNormal, double maxNormal) {
    final numValue = double.tryParse(value);
    if (numValue == null) return Colors.grey.shade300;
    
    if (numValue >= minNormal && numValue <= maxNormal) {
      return Colors.green.shade100; // Normal range - green
    } else if (numValue < minNormal * 0.8 || numValue > maxNormal * 1.2) {
      return Colors.red.shade100; // Critical range - red
    } else {
      return Colors.orange.shade100; // Warning range - orange
    }
  }

  Color _getBorderColor(String value, double minNormal, double maxNormal) {
    final numValue = double.tryParse(value);
    if (numValue == null) return Colors.grey.shade300;
    
    if (numValue >= minNormal && numValue <= maxNormal) {
      return Colors.green.shade400; // Normal range - green
    } else if (numValue < minNormal * 0.8 || numValue > maxNormal * 1.2) {
      return Colors.red.shade400; // Critical range - red
    } else {
      return Colors.orange.shade400; // Warning range - orange
    }
  }

  void _showMedicalConditionsModal() {
    final List<String> availableConditions = [
      'Hypertension',
      'Diabetes',
      'Heart disease',
      'Anemia',
      'Bleeding disorder',
      'Human immunodeficiency virus (HIV) and syphilis',
      'Tuberculosis (TB)',
      'Malaria',
    ];
    
    List<String> tempSelectedConditions = List.from(_selectedConditions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                constraints: const BoxConstraints(maxHeight: 500),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.medical_information,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent
                              : Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select Medical Conditions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Conditions List
                    Expanded(
                      child: ListView.builder(
                        itemCount: availableConditions.length,
                        itemBuilder: (context, index) {
                          final condition = availableConditions[index];
                          final isSelected = tempSelectedConditions.contains(condition);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    tempSelectedConditions.remove(condition);
                                  } else {
                                    tempSelectedConditions.add(condition);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent50
                                          : Colors.green.shade50)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? (ThemeController.instance.useShadcn.value
                                            ? ShadcnColors.accent200
                                            : Colors.green.shade200)
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (ThemeController.instance.useShadcn.value
                                                ? ShadcnColors.accent
                                                : Colors.green.shade600)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isSelected
                                              ? (ThemeController.instance.useShadcn.value
                                                  ? ShadcnColors.accent
                                                  : Colors.green.shade600)
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        condition,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? (ThemeController.instance.useShadcn.value
                                                  ? ShadcnColors.accent700
                                                  : Colors.green.shade700)
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedConditions = List.from(tempSelectedConditions);
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeController.instance.useShadcn.value
                                  ? ShadcnColors.accent
                                  : Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showObstetricHistoryModal() {
    final List<String> availableObstetricHistory = [
      'Cesarean section',
      'Miscarriage',
      'Stillbirth',
      'Preterm birth',
      'Low birth weight',
      'Gestational diabetes',
      'Preeclampsia',
      'Placental abruption',
      'Uterine rupture',
      'Postpartum hemorrhage',
    ];
    
    List<String> tempSelectedObstetricHistory = List.from(_selectedObstetricHistory);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                constraints: const BoxConstraints(maxHeight: 500),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.pregnant_woman,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent
                              : Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select Past Obstetric History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Obstetric History List
                    Expanded(
                      child: ListView.builder(
                        itemCount: availableObstetricHistory.length,
                        itemBuilder: (context, index) {
                          final obstetricHistory = availableObstetricHistory[index];
                          final isSelected = tempSelectedObstetricHistory.contains(obstetricHistory);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    tempSelectedObstetricHistory.remove(obstetricHistory);
                                  } else {
                                    tempSelectedObstetricHistory.add(obstetricHistory);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent50
                                          : Colors.green.shade50)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? (ThemeController.instance.useShadcn.value
                                            ? ShadcnColors.accent200
                                            : Colors.green.shade200)
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (ThemeController.instance.useShadcn.value
                                                ? ShadcnColors.accent
                                                : Colors.green.shade600)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isSelected
                                              ? (ThemeController.instance.useShadcn.value
                                                  ? ShadcnColors.accent
                                                  : Colors.green.shade600)
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        obstetricHistory,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? (ThemeController.instance.useShadcn.value
                                                  ? ShadcnColors.accent700
                                                  : Colors.green.shade700)
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedObstetricHistory = List.from(tempSelectedObstetricHistory);
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeController.instance.useShadcn.value
                                  ? ShadcnColors.accent
                                  : Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveAndContinueMedicalHistory() {
    // Validation disabled for testing purposes
    
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
        content: Text('Medical History saved successfully! Moving to ${_getNextTabName()}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveAndContinue() {
    // Validation disabled for testing purposes
    
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
      _showValidationError('Please enter a valid CNIC format (e.g., 12345-1234567-1 or 1234512345671)');
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
    // CNIC validation - accepts both with and without dashes
    // Format: 12345-1234567-1 or 1234512345671 (13 digits total)
    final cnicWithDashes = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    final cnicWithoutDashes = RegExp(r'^\d{13}$');
    return cnicWithDashes.hasMatch(cnic) || cnicWithoutDashes.hasMatch(cnic);
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

  String _getPreviousTabName() {
    const tabNames = ['Pregnancy Info', 'Medical History', 'Vitals', 'Ultrasound', 'Supplements', 'Referrals'];
    final prevIndex = _currentTabIndex - 1;
    if (prevIndex >= 0) {
      return tabNames[prevIndex];
    }
    return 'previous tab';
  }

  void _goBack() {
    if (_currentTabIndex > 0) {
      setState(() {
        _currentTabIndex = _currentTabIndex - 1;
        _tabController.animateTo(_currentTabIndex);
      });
    } else {
      // If on first tab, navigate back to previous page
      Navigator.of(context).pop();
    }
  }

  Widget _buildMedicalHistoryTab() {
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
                        'Medical History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record patient\'s medical background and obstetric history',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.medical_information,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent
                      : Colors.green.shade600,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Form Fields
          Row(
            children: [
              // History of Previous Illness
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History of Previous Illness',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeController.instance.useShadcn.value
                            ? ShadcnColors.accent700
                            : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Select Conditions Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showMedicalConditionsModal,
                        icon: Icon(
                          Icons.add,
                          size: 18,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent
                              : Colors.green.shade600,
                        ),
                        label: Text(
                          'Select Medical Conditions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent
                                : Colors.green.shade600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent
                                : Colors.green.shade600,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Selected Conditions Cards
                    if (_selectedConditions.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedConditions.map((condition) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeController.instance.useShadcn.value
                                    ? ShadcnColors.accent50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: ThemeController.instance.useShadcn.value
                                      ? ShadcnColors.accent200
                                      : Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    condition,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedConditions.remove(condition);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent600
                                          : Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),
              
              // Past Obstetric History
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Past Obstetric History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeController.instance.useShadcn.value
                            ? ShadcnColors.accent700
                            : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Select Obstetric History Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showObstetricHistoryModal,
                        icon: Icon(
                          Icons.add,
                          size: 18,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent
                              : Colors.green.shade600,
                        ),
                        label: Text(
                          'Select Obstetric History',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent
                                : Colors.green.shade600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent
                                : Colors.green.shade600,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Selected Obstetric History Cards
                    if (_selectedObstetricHistory.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedObstetricHistory.map((obstetricHistory) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeController.instance.useShadcn.value
                                    ? ShadcnColors.accent50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: ThemeController.instance.useShadcn.value
                                      ? ShadcnColors.accent200
                                      : Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    obstetricHistory,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedObstetricHistory.remove(obstetricHistory);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent600
                                          : Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox.shrink(),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetMedicalHistoryFields();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _saveAndContinueMedicalHistory();
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

  Widget _buildVitalsTab() {
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
                        'Vitals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record patient\'s vital signs and measurements',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.monitor_heart,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent
                      : Colors.green.shade600,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Form Fields
          Column(
            children: [
              // Row 1: Height, Weight, BMI, Weight Gain
              Row(
                children: [
                  Expanded(
                    child: _buildVitalsField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      hint: 'Enter height',
                      isRequired: true,
                      onChanged: _calculateBMI,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsField(
                      controller: _weightController,
                      label: 'Weight (1-220) (kg)',
                      hint: 'Enter weight',
                      isRequired: true,
                      onChanged: _calculateBMI,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsField(
                      controller: _bmiController,
                      label: 'BMI',
                      hint: 'Auto-calculated',
                      isReadOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsField(
                      controller: _weightGainController,
                      label: 'Weight Gain',
                      hint: 'Enter weight gain',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 2: BP, Temperature, Blood Group
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BP (Normal: 90-140/60-90)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVitalsFieldWithValidation(
                                controller: _systolicController,
                                label: 'Systolic (50-250)',
                                hint: 'Enter systolic',
                                isRequired: true,
                                showLabel: false,
                                minNormal: 90,
                                maxNormal: 140,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('/'),
                            ),
                            Expanded(
                              child: _buildVitalsFieldWithValidation(
                                controller: _diastolicController,
                                label: 'Diastolic (30-200)',
                                hint: 'Enter diastolic',
                                isRequired: true,
                                showLabel: false,
                                minNormal: 60,
                                maxNormal: 90,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsField(
                      controller: _temperatureController,
                      label: 'Temperature (96-106) (°F)',
                      hint: 'Enter temperature',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBloodGroupDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 3: HB, Fundal Height, BSR, Albumin
              Row(
                children: [
                  Expanded(
                    child: _buildVitalsFieldWithValidation(
                      controller: _hbController,
                      label: 'HB (g/dl) (Normal: 11-15)',
                      hint: 'Enter HB level',
                      isRequired: true,
                      minNormal: 11,
                      maxNormal: 15,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsFieldWithValidation(
                      controller: _fundalHeightController,
                      label: 'Fundal Height Week (Normal: 20-40)',
                      hint: 'Enter fundal height',
                      minNormal: 20,
                      maxNormal: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsFieldWithValidation(
                      controller: _bsrController,
                      label: 'BSR (mg/dl) (Normal: 70-140)',
                      hint: 'Enter BSR level',
                      isRequired: true,
                      minNormal: 70,
                      maxNormal: 140,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsField(
                      controller: _albuminController,
                      label: 'Albumin On Urine Dipstick (Normal: Negative)',
                      hint: 'Enter albumin level',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 4: MUAC, Danger Signs
              Row(
                children: [
                  Expanded(
                    child: _buildVitalsFieldWithValidation(
                      controller: _muacController,
                      label: 'MUAC (cm) (Normal: 23-32)',
                      hint: 'Enter MUAC',
                      minNormal: 23,
                      maxNormal: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVitalsField(
                      controller: _dangerSignsController,
                      label: 'Danger Signs (Normal: None)',
                      hint: 'Enter danger signs',
                      isRequired: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox.shrink(),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetVitalsFields();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _saveAndContinueVitals();
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

  Widget _buildVitalsField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    bool isReadOnly = false,
    bool showLabel = true,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent700
                      : Colors.green.shade700,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
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
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          onChanged: onChanged != null ? (_) => onChanged() : null,
        ),
      ],
    );
  }

  Widget _buildVitalsFieldWithValidation({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    bool isReadOnly = false,
    bool showLabel = true,
    required double minNormal,
    required double maxNormal,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent700
                      : Colors.green.shade700,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _getBorderColor(controller.text, minNormal, maxNormal),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isReadOnly 
                ? Colors.grey.shade100 
                : _getFieldColor(controller.text, minNormal, maxNormal),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          onChanged: (value) {
            setState(() {
              // Trigger rebuild to update colors
            });
            if (onChanged != null) onChanged();
          },
        ),
      ],
    );
  }

  Widget _buildBloodGroupDropdown() {
    final List<String> bloodGroups = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Group',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeController.instance.useShadcn.value
                ? ShadcnColors.accent700
                : Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          decoration: InputDecoration(
            hintText: 'Select blood group',
            border: OutlineInputBorder(
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
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          items: bloodGroups.map((String bloodGroup) {
            return DropdownMenuItem<String>(
              value: bloodGroup,
              child: Text(bloodGroup),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBloodGroup = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUltrasoundTab() {
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
                        'Ultrasound',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record ultrasound findings and fetal information',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.pregnant_woman,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent
                      : Colors.green.shade600,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Ultrasound Conducted Radio Button
          Text(
            'Ultrasound conducted?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _ultrasoundConducted,
                onChanged: (bool? value) {
                  setState(() {
                    _ultrasoundConducted = value ?? false;
                  });
                },
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
              ),
              const Text('Yes'),
              const SizedBox(width: 24),
              Radio<bool>(
                value: false,
                groupValue: _ultrasoundConducted,
                onChanged: (bool? value) {
                  setState(() {
                    _ultrasoundConducted = value ?? false;
                  });
                },
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
              ),
              const Text('No'),
            ],
          ),
          
          // Conditional Form Fields
          if (_ultrasoundConducted) ...[
            const SizedBox(height: 24),
            
            // Row 1: Type of Pregnancy, Fetal Movement, Presentation
            Row(
              children: [
                Expanded(
                  child: _buildUltrasoundDropdown(
                    value: _selectedTypeOfPregnancy,
                    label: 'Type of pregnancy',
                    hint: 'Select Type of Pregnancy',
                    isRequired: true,
                    items: ['Single', 'Twin', 'Triplets'],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedTypeOfPregnancy = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUltrasoundDropdown(
                    value: _selectedFetalMovement,
                    label: 'Fetal Movement',
                    hint: 'Select Fetal Movement',
                    isRequired: true,
                    items: ['Yes', 'No'],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedFetalMovement = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPresentationDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Row 2: Delivery Type, Placenta, Placenta Condition, Liquor
            Row(
              children: [
                Expanded(
                  child: _buildUltrasoundDropdown(
                    value: _selectedDeliveryType,
                    label: 'Delivery type',
                    hint: 'Select Delivery Type',
                    isRequired: false,
                    items: ['Normal', 'Cesarean', 'Assisted', 'Emergency'],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedDeliveryType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUltrasoundDropdown(
                    value: _selectedPlacenta,
                    label: 'Placenta',
                    hint: 'Select Placenta',
                    isRequired: true,
                    items: ['Anterior', 'Posterior', 'Fundal', 'Lateral'],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPlacenta = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUltrasoundDropdown(
                    value: _selectedPlacentaCondition,
                    label: 'Placenta Condition',
                    hint: 'Select Placenta Condition',
                    isRequired: true,
                    items: ['Normal', 'Low-lying', 'Previa', 'Abruption'],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPlacentaCondition = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUltrasoundDropdown(
                    value: _selectedLiquor,
                    label: 'Liquor',
                    hint: 'Select Liquor',
                    isRequired: true,
                    items: ['N/A', 'Adequate', 'Scanty', 'Inadequate', 'Excessive'],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLiquor = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Row 3: Fetal Heart Rate
            Row(
              children: [
                Expanded(
                  child: _buildUltrasoundField(
                    controller: _fetalHeartRateController,
                    label: 'Fetal Heart Rate',
                    hint: 'Enter fetal heart rate',
                    isRequired: true,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox.shrink(),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetUltrasoundFields();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _saveAndContinueUltrasound();
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

  Widget _buildUltrasoundField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
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
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade700,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
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
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUltrasoundDropdown({
    required String? value,
    required String label,
    required String hint,
    required bool isRequired,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade700,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
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
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPresentationDropdown() {
    final List<String> presentationOptions = [
      'N/A',
      'Longitudinal',
      'Cephalic',
      'Breech',
      'Shoulder',
      'Transverse',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Presentation of fetus',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPresentation,
          decoration: InputDecoration(
            hintText: 'Select Presentation of Fetus',
            border: OutlineInputBorder(
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
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          items: presentationOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedPresentation = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSupplementsTab() {
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
                        'Supplements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record supplements given to the patient',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.medication,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent
                      : Colors.green.shade600,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Supplements Given Radio Button
          Text(
            'Supplements Given?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _supplementsGiven,
                onChanged: (bool? value) {
                  setState(() {
                    _supplementsGiven = value ?? false;
                  });
                },
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
              ),
              const Text('Yes'),
              const SizedBox(width: 24),
              Radio<bool>(
                value: false,
                groupValue: _supplementsGiven,
                onChanged: (bool? value) {
                  setState(() {
                    _supplementsGiven = value ?? false;
                  });
                },
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
              ),
              const Text('No'),
            ],
          ),
          
          // Conditional Supplements Management
          if (_supplementsGiven) ...[
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Add Supplements Detail Below',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            
            // Supplements List Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Column Headers
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 48), // Space for delete button
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Supplements List
                  if (_selectedSupplements.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No supplements added yet. Click ADD to add supplements.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedSupplements.length,
                      itemBuilder: (context, index) {
                        final supplement = _selectedSupplements[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  supplement['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ThemeController.instance.useShadcn.value
                                        ? ShadcnColors.accent700
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ),
                              Text(
                                '${supplement['quantity']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeController.instance.useShadcn.value
                                      ? ShadcnColors.accent700
                                      : Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedSupplements.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ADD Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSupplementsModal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeController.instance.useShadcn.value
                        ? ShadcnColors.accent
                        : Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox.shrink(),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetSupplementsFields();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _saveAndContinueSupplements();
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

  Widget _buildReferralsTab() {
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
                        'Referrals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record patient referrals to secondary health facilities',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.local_hospital,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent
                      : Colors.green.shade600,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Patient Referred Radio Button
          Text(
            'Did you refer the patient to a secondary health facility?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _patientReferred,
                onChanged: (bool? value) {
                  setState(() {
                    _patientReferred = value ?? false;
                  });
                },
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
              ),
              const Text('Yes'),
              const SizedBox(width: 24),
              Radio<bool>(
                value: false,
                groupValue: _patientReferred,
                onChanged: (bool? value) {
                  setState(() {
                    _patientReferred = value ?? false;
                  });
                },
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
              ),
              const Text('No'),
            ],
          ),
          
          // Conditional Referral Details
          if (_patientReferred) ...[
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Where were they referred to?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            
            // Referral Details Form
            Column(
              children: [
                // Row 1: District and Type
                Row(
                  children: [
                    Expanded(
                      child: _buildReferralsDropdown(
                        value: _selectedDistrict,
                        label: 'District',
                        hint: 'Select District',
                        items: [
                          'Bahawalnagar',
                          'Bahawalpur',
                          'Rahim Yar Khan',
                          'Lahore',
                          'Karachi',
                          'Islamabad',
                          'Rawalpindi',
                          'Faisalabad',
                          'Multan',
                          'Peshawar',
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _selectedDistrict = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildReferralsDropdown(
                        value: _selectedType,
                        label: 'Type',
                        hint: 'Select Type',
                        items: [
                          'DHQ',
                          'THQ',
                          'RHC',
                          'BHU',
                          'Private Hospital',
                          'Specialist Clinic',
                          'Teaching Hospital',
                          'General Hospital',
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Row 2: Health Facility
                Row(
                  children: [
                    Expanded(
                      child: _buildReferralsDropdown(
                        value: _selectedHealthFacility,
                        label: 'Health Facility',
                        hint: 'Select Health Facility',
                        items: [
                          'District Headquarter Hospital, Bahawalnagar',
                          'District Headquarter Hospital, Bahawalpur',
                          'District Headquarter Hospital, Rahim Yar Khan',
                          'Allama Iqbal Medical College, Lahore',
                          'Jinnah Hospital, Lahore',
                          'Aga Khan Hospital, Karachi',
                          'Shifa International Hospital, Islamabad',
                          'Holy Family Hospital, Rawalpindi',
                          'Allied Hospital, Faisalabad',
                          'Nishtar Hospital, Multan',
                          'Lady Reading Hospital, Peshawar',
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _selectedHealthFacility = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox.shrink(),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetReferralsFields();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _saveAndContinueReferrals();
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

  Widget _buildReferralsDropdown({
    required String? value,
    required String label,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeController.instance.useShadcn.value
                ? ShadcnColors.accent700
                : Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
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
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

}

