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

class DeliveryNewbornPage extends StatefulWidget {
  const DeliveryNewbornPage({super.key});

  @override
  State<DeliveryNewbornPage> createState() => _DeliveryNewbornPageState();
}

class _DeliveryNewbornPageState extends State<DeliveryNewbornPage> with TickerProviderStateMixin {
  late VoidCallback _patientListener;
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Tab completion status
  List<bool> _tabCompleted = [true, false, false]; // First tab enabled by default
  
  // Initial Assessment Form Controllers
  final TextEditingController _bsrController = TextEditingController();
  final TextEditingController _hbController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _cervicalDilatationController = TextEditingController();
  final TextEditingController _amnioticFluidController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  
  // Initial Assessment State Variables
  String? _fetalMovement; // 'Yes' or 'No'
  String? _membraneRuptured; // 'Yes' or 'No'
  String? _hoursSinceRupture; // '1-3 hours' or 'More than 3 hours'
  String? _progressToNextStage; // 'False Labor', 'Proceed to delivery', 'Refer'
  
  // Tab names
  final List<String> tabNames = [
    'Initial Assessment',
    'Delivery Assessment', 
    'Discharge & Referrals'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    _patientListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    PatientManager.addListener(_patientListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    PatientManager.removeListener(_patientListener);
    
    // Dispose controllers
    _bsrController.dispose();
    _hbController.dispose();
    _temperatureController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _cervicalDilatationController.dispose();
    _amnioticFluidController.dispose();
    _remarksController.dispose();
    
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  String _getNextTabName() {
    int nextIndex = _currentTabIndex + 1;
    if (nextIndex < tabNames.length) {
      return tabNames[nextIndex];
    }
    return 'Complete';
  }

  String _getPreviousTabName() {
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ThemeController.instance.useShadcn.value
          ? Colors.grey.shade50
          : Colors.green.shade50,
      body: SideNavigationDrawer(
        currentRoute: '/delivery-newborn',
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
                    tabs: tabNames,
                    children: [
                      _buildInitialAssessmentTab(),
                      _buildDeliveryAssessmentTab(),
                      _buildDischargeReferralsTab(),
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

  Widget _buildInitialAssessmentTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
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
                              'Initial Assessment',
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
                              'Record vital signs and initial medical assessment',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.assessment_outlined,
                        color: ThemeController.instance.useShadcn.value
                            ? ShadcnColors.accent
                            : Colors.green.shade600,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vital Signs Section
                        _buildSectionTitle('Vital Signs'),
                        const SizedBox(height: 12),
                        
                        // First row - BSR, HB, Temperature
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _bsrController,
                                label: 'BSR (mg/dl)',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _hbController,
                                label: 'HB (g/dl)',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _temperatureController,
                                label: 'Temperature (°F)',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Second row - BP and Cervical Dilatation
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'BP',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ThemeController.instance.useShadcn.value
                                              ? ShadcnColors.accent700
                                              : Colors.green.shade700,
                                        ),
                                      ),
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
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextFormField(
                                          controller: _systolicController,
                                          label: 'Systolic',
                                          isRequired: true,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '/',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildTextFormField(
                                          controller: _diastolicController,
                                          label: 'Diastolic',
                                          isRequired: true,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _cervicalDilatationController,
                                label: 'Cervical Dilatation',
                                isRequired: true,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Fetal and Membrane Status Section
                        _buildSectionTitle('Fetal and Membrane Status'),
                        const SizedBox(height: 12),
                        
                        // Fetal Movement and Membrane Ruptured in same row
                        Row(
                          children: [
                            Expanded(
                              child: _buildRadioGroup(
                                title: 'Fetal Movement',
                                isRequired: true,
                                value: _fetalMovement,
                                options: ['Yes', 'No'],
                                onChanged: (value) {
                                  setState(() {
                                    _fetalMovement = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildRadioGroup(
                                title: 'Membrane Ruptured',
                                isRequired: true,
                                value: _membraneRuptured,
                                options: ['Yes', 'No'],
                                onChanged: (value) {
                                  setState(() {
                                    _membraneRuptured = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Amniotic Fluid and Rupture Time Section
                        _buildSectionTitle('Amniotic Fluid and Rupture Time'),
                        const SizedBox(height: 12),
                        
                        // Amniotic Fluid and Hours since rupture in same row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _amnioticFluidController,
                                label: 'Amniotic Fluid',
                                isRequired: true,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildRadioGroup(
                                title: 'Hours since rupture',
                                isRequired: true,
                                value: _hoursSinceRupture,
                                options: ['1-3 hours', 'More than 3 hours'],
                                onChanged: (value) {
                                  setState(() {
                                    _hoursSinceRupture = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Progress Assessment Section
                        _buildSectionTitle('Progress Assessment'),
                        const SizedBox(height: 12),
                        
                        // Progress to next stage
                        _buildRadioGroup(
                          title: 'Progress to next stage',
                          isRequired: true,
                          value: _progressToNextStage,
                          options: ['False Labor', 'Proceed to delivery', 'Refer'],
                          onChanged: (value) {
                            setState(() {
                              _progressToNextStage = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Remarks
                        _buildTextFormField(
                          controller: _remarksController,
                          label: 'Remarks',
                          isRequired: false,
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Action buttons
        const SizedBox(height: 16),
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
                onPressed: _resetInitialAssessmentFields,
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
                onPressed: _saveAndContinueInitialAssessment,
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
                child: Text(
                  'Save and Continue to ${_getNextTabName()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAssessmentTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Assessment',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ShadcnColors.foreground,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Placeholder content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_hospital_outlined,
                          size: 64,
                          color: ShadcnColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Delivery Assessment Form',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Form fields will be added here',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Action buttons
        const SizedBox(height: 16),
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
                onPressed: _resetDeliveryAssessmentFields,
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
                onPressed: _saveAndContinueDeliveryAssessment,
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
                child: Text(
                  'Save and Continue to ${_getNextTabName()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDischargeReferralsTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discharge & Referrals',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ShadcnColors.foreground,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Placeholder content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.exit_to_app_outlined,
                          size: 64,
                          color: ShadcnColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Discharge & Referrals Form',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Form fields will be added here',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Action buttons
        const SizedBox(height: 16),
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
                onPressed: _resetDischargeReferralsFields,
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
                onPressed: _saveAndContinueDischargeReferrals,
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
                  'Save and Complete',
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
    );
  }

  // Helper methods for form widgets
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ThemeController.instance.useShadcn.value
            ? ShadcnColors.accent700
            : Colors.green.shade700,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required bool isRequired,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
          maxLines: maxLines,
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
          ),
        ),
      ],
    );
  }

  String _getHintText(String label) {
    if (label.contains('BSR')) return 'Enter BSR value';
    if (label.contains('HB')) return 'Enter HB value';
    if (label.contains('Temperature')) return 'Enter temperature';
    if (label.contains('Systolic')) return 'Enter systolic BP';
    if (label.contains('Diastolic')) return 'Enter diastolic BP';
    if (label.contains('Cervical')) return 'Enter cervical dilatation';
    if (label.contains('Amniotic')) return 'Enter amniotic fluid status';
    if (label.contains('Remarks')) return 'Enter any additional remarks';
    return 'Enter value';
  }

  Widget _buildRadioGroup({
    required String title,
    required bool isRequired,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
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
        Wrap(
          spacing: 16,
          children: options.map((option) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: option,
                groupValue: value,
                onChanged: onChanged,
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent
                    : Colors.green.shade600,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                option,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )).toList(),
        ),
      ],
    );
  }

  // Reset methods
  void _resetInitialAssessmentFields() {
    setState(() {
      // Clear text controllers
      _bsrController.clear();
      _hbController.clear();
      _temperatureController.clear();
      _systolicController.clear();
      _diastolicController.clear();
      _cervicalDilatationController.clear();
      _amnioticFluidController.clear();
      _remarksController.clear();
      
      // Reset radio button selections
      _fetalMovement = null;
      _membraneRuptured = null;
      _hoursSinceRupture = null;
      _progressToNextStage = null;
    });
  }

  void _resetDeliveryAssessmentFields() {
    // TODO: Implement reset logic for Delivery Assessment
    setState(() {});
  }

  void _resetDischargeReferralsFields() {
    // TODO: Implement reset logic for Discharge & Referrals
    setState(() {});
  }

  // Validation method
  bool _validateInitialAssessmentForm() {
    // Check required text fields
    if (_bsrController.text.trim().isEmpty ||
        _hbController.text.trim().isEmpty ||
        _temperatureController.text.trim().isEmpty ||
        _systolicController.text.trim().isEmpty ||
        _diastolicController.text.trim().isEmpty ||
        _cervicalDilatationController.text.trim().isEmpty ||
        _amnioticFluidController.text.trim().isEmpty) {
      _showValidationError('Please fill in all required fields');
      return false;
    }
    
    // Check required radio button selections
    if (_fetalMovement == null ||
        _membraneRuptured == null ||
        _hoursSinceRupture == null ||
        _progressToNextStage == null) {
      _showValidationError('Please select all required options');
      return false;
    }
    
    // Validate numeric ranges
    final temperature = double.tryParse(_temperatureController.text);
    if (temperature != null && (temperature < 96 || temperature > 106)) {
      _showValidationError('Temperature must be between 96-106°F');
      return false;
    }
    
    final systolic = int.tryParse(_systolicController.text);
    if (systolic != null && (systolic < 50 || systolic > 250)) {
      _showValidationError('Systolic BP must be between 50-250');
      return false;
    }
    
    final diastolic = int.tryParse(_diastolicController.text);
    if (diastolic != null && (diastolic < 30 || diastolic > 200)) {
      _showValidationError('Diastolic BP must be between 30-200');
      return false;
    }
    
    return true;
  }
  
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Save and continue methods
  void _saveAndContinueInitialAssessment() {
    // Validation temporarily disabled for testing
    // TODO: Re-enable validation when requested
    // if (_validateInitialAssessmentForm()) {
      // TODO: Save form data to backend/database
      setState(() {
        _tabCompleted[0] = true;
        if (_currentTabIndex < tabNames.length - 1) {
          _currentTabIndex++;
          _tabCompleted[_currentTabIndex] = true; // Enable next tab
          _tabController.animateTo(_currentTabIndex);
        }
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Initial Assessment saved successfully'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    // }
  }

  void _saveAndContinueDeliveryAssessment() {
    // Validation temporarily disabled for testing
    // TODO: Re-enable validation when requested
    setState(() {
      _tabCompleted[1] = true;
      if (_currentTabIndex < tabNames.length - 1) {
        _currentTabIndex++;
        _tabCompleted[_currentTabIndex] = true; // Enable next tab
        _tabController.animateTo(_currentTabIndex);
      }
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Delivery Assessment saved successfully'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveAndContinueDischargeReferrals() {
    // Validation temporarily disabled for testing
    // TODO: Re-enable validation when requested
    setState(() {
      _tabCompleted[2] = true;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Discharge & Referrals saved successfully'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Navigate back to Pregnancy Dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PregnancyDashboard(),
      ),
    );
  }
}
