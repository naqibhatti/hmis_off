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
  final TextEditingController _initialTemperatureController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _cervicalDilatationController = TextEditingController();
  final TextEditingController _amnioticFluidController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  
  // Initial Assessment State Variables
  String? _fetalMovement; // 'Yes' or 'No'
  String? _membraneRuptured; // 'Yes' or 'No'
  String? _hoursSinceRupture; // '1-3 hours' or 'More than 3 hours'
  String? _initialProgressToNextStage; // 'False Labor', 'Proceed to delivery', 'Refer'
  
  // Delivery Assessment State Variables
  String? _conditionOfMother; // 'Please Select', 'Alive and healthy', 'Alive and unhealthy', 'Dead'
  List<String> _selectedCausesOfDeath = []; // Selected causes of death
  
  // Alive condition form controllers
  final TextEditingController _deliveryTemperatureController = TextEditingController();
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _immediateStepsController = TextEditingController();
  final TextEditingController _symptomsAssessmentController = TextEditingController();
  final TextEditingController _medicinesAdministeredController = TextEditingController();
  String? _deliveryProgressToNextStage; // 'Continue' or 'Refer'
  
   // Newborn form controllers and state
   final TextEditingController _newbornWeightController = TextEditingController();
   final TextEditingController _newbornTemperatureController = TextEditingController();
   final TextEditingController _newbornCauseOfDeathController = TextEditingController();
   String? _newbornGender; // 'Male' or 'Female'
   String? _newbornCondition; // 'Alive and Healthy', 'Alive and Unhealthy', 'Dead after delivery', 'Intrauterine death'
   List<String> _selectedNewbornSymptoms = []; // Selected symptoms
   List<String> _selectedNewbornMedications = []; // Selected medications/vaccines
   
   // Child records storage
   List<Map<String, dynamic>> _childRecords = [];
  
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
    _initialTemperatureController.dispose();
    _deliveryTemperatureController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _cervicalDilatationController.dispose();
    _amnioticFluidController.dispose();
    _remarksController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _immediateStepsController.dispose();
    _symptomsAssessmentController.dispose();
     _medicinesAdministeredController.dispose();
     _newbornWeightController.dispose();
     _newbornTemperatureController.dispose();
     _newbornCauseOfDeathController.dispose();
    
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
                        // Back button to pregnancy dashboard
                        IconButton(
                          tooltip: 'Back to Pregnancy Dashboard',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => PregnancyDashboard(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                
                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vital Signs Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                      controller: _initialTemperatureController,
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Fetal and Membrane Status Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Amniotic Fluid and Rupture Time Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Progress Assessment Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        _buildSectionTitle('Progress Assessment'),
                        const SizedBox(height: 12),
                        
                        // Progress to next stage
                        _buildRadioGroup(
                          title: 'Progress to next stage',
                          isRequired: true,
                                value: _initialProgressToNextStage,
                          options: ['False Labor', 'Proceed to delivery', 'Refer'],
                          onChanged: (value) {
                            setState(() {
                                    _initialProgressToNextStage = value;
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
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _goBack,
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox.shrink(),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.tonal(
                  onPressed: _resetInitialAssessmentFields,
                  child: const Text('Reset'),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _saveAndContinueInitialAssessment,
                  style: FilledButton.styleFrom(
                    backgroundColor: _initialProgressToNextStage == 'False Labor' 
                        ? Colors.orange.shade600 
                        : ShadcnColors.accent600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _initialProgressToNextStage == 'False Labor' 
                        ? 'Save and Exit (False Labor)'
                        : 'Save and Continue to ${_getNextTabName()}',
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
                
                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Condition of mother and Cause of Death fields
                        Row(
                          children: [
                            // Condition of mother field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Condition of mother',
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
                                    value: _conditionOfMother,
                                    decoration: InputDecoration(
                                      hintText: 'Please Select',
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
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Please Select',
                                        child: Text('Please Select'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Alive and healthy',
                                        child: Text('Alive and healthy'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Alive and unhealthy',
                                        child: Text('Alive and unhealthy'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Dead',
                                        child: Text('Dead'),
                                      ),
                                    ],
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _conditionOfMother = newValue;
                                        if (newValue != 'Dead') {
                                          _selectedCausesOfDeath.clear();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            // Cause of Death field (only shown when Dead is selected)
                            if (_conditionOfMother == 'Dead') ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Cause of Death',
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
                                    InkWell(
                                      onTap: () => _showCauseOfDeathModal(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: _selectedCausesOfDeath.isEmpty
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Select causes',
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ),
                        Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: _selectedCausesOfDeath.map((cause) {
                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: ThemeController.instance.useShadcn.value
                                                              ? ShadcnColors.accent100
                                                              : Colors.green.shade100,
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
                                                            Flexible(
                                                              child: Text(
                                                                cause,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: ThemeController.instance.useShadcn.value
                                                                      ? ShadcnColors.accent700
                                                                      : Colors.green.shade700,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 4),
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  _selectedCausesOfDeath.remove(cause);
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
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Icon(
                                                        Icons.arrow_drop_down,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        // Additional fields for alive conditions
                        if (_conditionOfMother == 'Alive and healthy' || _conditionOfMother == 'Alive and unhealthy') ...[
                          const SizedBox(height: 24),
                          
                          // Row 1: Vital Signs
                          Row(
                            children: [
                              // Temperature field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Temperature (96-106) (°F)',
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
                                    TextFormField(
                                      controller: _deliveryTemperatureController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter temperature',
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
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // BP Systolic field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'BP Systolic (50-250)',
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
                                    TextFormField(
                                      controller: _bpSystolicController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter systolic BP',
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
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // BP Diastolic field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'BP Diastolic (30-200)',
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
                                    TextFormField(
                                      controller: _bpDiastolicController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter diastolic BP',
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
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Row 2: Assessment Details
                          Row(
                            children: [
                              // Immediate steps field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Immediate steps',
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
                                    TextFormField(
                                      controller: _immediateStepsController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Enter immediate steps taken',
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
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Symptoms assessment field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Symptoms assessment',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeController.instance.useShadcn.value
                                            ? ShadcnColors.accent700
                                            : Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _symptomsAssessmentController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Enter symptoms assessment',
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
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Medicines administered field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Medicines administered',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeController.instance.useShadcn.value
                                            ? ShadcnColors.accent700
                                            : Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _medicinesAdministeredController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Enter medicines administered',
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
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Row 3: Progress Decision
                          Row(
                            children: [
                              Text(
                                'Progress to next stage',
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
                              const SizedBox(width: 16),
                              Radio<String>(
                                value: 'Continue',
                                groupValue: _deliveryProgressToNextStage,
                                onChanged: (String? value) {
                                  setState(() {
                                    _deliveryProgressToNextStage = value;
                                  });
                                },
                                activeColor: ThemeController.instance.useShadcn.value
                                    ? ShadcnColors.accent
                                    : Colors.green.shade600,
                              ),
                              const Text('Continue'),
                              const SizedBox(width: 24),
                              Radio<String>(
                                value: 'Refer',
                                groupValue: _deliveryProgressToNextStage,
                                onChanged: (String? value) {
                                  setState(() {
                                    _deliveryProgressToNextStage = value;
                                  });
                                },
                                activeColor: ThemeController.instance.useShadcn.value
                                    ? ShadcnColors.accent
                                    : Colors.green.shade600,
                              ),
                              const Text('Refer'),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // ADD CHILD button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showAddChildModal(),
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
                                elevation: 2,
                              ),
                              child: const Text(
                                'ADD CHILD',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                         // Records section
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(24),
                           decoration: BoxDecoration(
                             color: Colors.grey.shade50,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(
                               color: Colors.grey.shade200,
                             ),
                           ),
                           child: _childRecords.isEmpty
                               ? Column(
                                   children: [
                                     Icon(
                                       Icons.list_alt_outlined,
                                       size: 48,
                          color: ShadcnColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                                       'No record added',
                                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ShadcnColors.mutedForeground,
                                         fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                                       'Child records will appear here',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                      ],
                                 )
                               : Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.child_care,
                                           size: 20,
                                           color: ThemeController.instance.useShadcn.value
                                               ? ShadcnColors.accent700
                                               : Colors.green.shade700,
                                         ),
                                         const SizedBox(width: 8),
                                         Text(
                                           'Child Records (${_childRecords.length})',
                                           style: TextStyle(
                                             fontSize: 16,
                                             fontWeight: FontWeight.w600,
                                             color: ThemeController.instance.useShadcn.value
                                                 ? ShadcnColors.accent700
                                                 : Colors.green.shade700,
                                           ),
                                         ),
                                       ],
                                     ),
                                     const SizedBox(height: 16),
                                     ListView.builder(
                                       shrinkWrap: true,
                                       physics: const NeverScrollableScrollPhysics(),
                                       itemCount: _childRecords.length,
                                       itemBuilder: (context, index) {
                                         final record = _childRecords[index];
                                         return Container(
                                           margin: const EdgeInsets.only(bottom: 12),
                                           padding: const EdgeInsets.all(16),
                                           decoration: BoxDecoration(
                                             color: Colors.white,
                                             borderRadius: BorderRadius.circular(8),
                                             border: Border.all(
                                               color: Colors.grey.shade300,
                                             ),
                                           ),
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Row(
                                                 children: [
                                                   Container(
                                                     padding: const EdgeInsets.symmetric(
                                                       horizontal: 8,
                                                       vertical: 4,
                                                     ),
                                                     decoration: BoxDecoration(
                                                       color: ThemeController.instance.useShadcn.value
                                                           ? ShadcnColors.accent100
                                                           : Colors.green.shade100,
                                                       borderRadius: BorderRadius.circular(4),
                                                     ),
                                                     child: Text(
                                                       'Child ${index + 1}',
                                                       style: TextStyle(
                                                         fontSize: 12,
                                                         fontWeight: FontWeight.w600,
                                                         color: ThemeController.instance.useShadcn.value
                                                             ? ShadcnColors.accent700
                                                             : Colors.green.shade700,
                                                       ),
                                                     ),
                                                   ),
                                                   const Spacer(),
                                                   Text(
                                                     '${record['gender']} • ${record['weight']}kg • ${record['temperature']}°F',
                                                     style: const TextStyle(
                                                       fontSize: 14,
                                                       fontWeight: FontWeight.w500,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               const SizedBox(height: 8),
                                               Text(
                                                 'Condition: ${record['condition']}',
                                                 style: const TextStyle(
                                                   fontSize: 14,
                                                   fontWeight: FontWeight.w500,
                                                 ),
                                               ),
                                               if (record['symptoms'].isNotEmpty) ...[
                                                 const SizedBox(height: 4),
                                                 Text(
                                                   'Symptoms: ${record['symptoms'].join(', ')}',
                                                   style: TextStyle(
                                                     fontSize: 12,
                                                     color: Colors.grey.shade600,
                                                   ),
                                                 ),
                                               ],
                                               if (record['medications'].isNotEmpty) ...[
                                                 const SizedBox(height: 4),
                                                 Text(
                                                   'Medications: ${record['medications'].join(', ')}',
                                                   style: TextStyle(
                                                     fontSize: 12,
                                                     color: Colors.grey.shade600,
                                                   ),
                                                 ),
                                               ],
                                               if (record['causeOfDeath'].isNotEmpty) ...[
                                                 const SizedBox(height: 4),
                                                 Text(
                                                   'Cause of Death: ${record['causeOfDeath']}',
                                                   style: TextStyle(
                                                     fontSize: 12,
                                                     color: Colors.red.shade600,
                                                   ),
                                                 ),
                                               ],
                                             ],
                                           ),
                                         );
                                       },
                                     ),
                                   ],
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
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _goBack,
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox.shrink(),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.tonal(
                  onPressed: _resetDeliveryAssessmentFields,
                  child: const Text('Reset'),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _saveAndContinueDeliveryAssessment,
                  style: FilledButton.styleFrom(
                    backgroundColor: ShadcnColors.accent600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Save and Continue to ${_getNextTabName()}',
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
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _goBack,
                  child: Text(
                    _currentTabIndex > 0 ? 'Back to ${_getPreviousTabName()}' : 'Cancel',
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox.shrink(),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.tonal(
                  onPressed: _resetDischargeReferralsFields,
                  child: const Text('Reset'),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _saveAndContinueDischargeReferrals,
                  style: FilledButton.styleFrom(
                    backgroundColor: ShadcnColors.accent600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save and Complete'),
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
      _initialTemperatureController.clear();
      _systolicController.clear();
      _diastolicController.clear();
      _cervicalDilatationController.clear();
      _amnioticFluidController.clear();
      _remarksController.clear();
      
      // Reset radio button selections
      _fetalMovement = null;
      _membraneRuptured = null;
      _hoursSinceRupture = null;
      _initialProgressToNextStage = null;
      _deliveryProgressToNextStage = null;
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
        _initialTemperatureController.text.trim().isEmpty ||
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
        _initialProgressToNextStage == null) {
      _showValidationError('Please select all required options');
      return false;
    }
    
    // Validate numeric ranges
    final temperature = double.tryParse(_initialTemperatureController.text);
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
    // Check if False Labor is selected
    if (_initialProgressToNextStage == 'False Labor') {
      // Save the form data and exit
      _saveFormDataAndExit();
      return;
    }
    
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

  void _saveFormDataAndExit() {
    // TODO: Save form data to backend/database
    // For now, just show a success message and navigate back
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('False Labor case saved successfully. Returning to dashboard.'),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Navigate back to pregnancy dashboard after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PregnancyDashboard(),
        ),
      );
    });
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

  void _showCauseOfDeathModal() {
    final List<String> causesOfDeath = [
      'Pregnancies with abortive outcome',
      'Hypertensive disorders in pregnancy, childbirth, and the puerperium',
      'Obstetric haemorrhage',
      'Pregnancy-related infection',
      'Other obstetric complications',
      'Unanticipated complications of management',
      'Non-obstetric complications',
      'Unknown/undetermined',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cause of Death',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ThemeController.instance.useShadcn.value
                            ? ShadcnColors.accent700
                            : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: causesOfDeath.length,
                        itemBuilder: (context, index) {
                          final cause = causesOfDeath[index];
                          final isSelected = _selectedCausesOfDeath.contains(cause);
                          
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  _selectedCausesOfDeath.remove(cause);
                                } else {
                                  _selectedCausesOfDeath.add(cause);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? (ThemeController.instance.useShadcn.value
                                                ? ShadcnColors.accent
                                                : Colors.green.shade600)
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      color: isSelected
                                          ? (ThemeController.instance.useShadcn.value
                                              ? ShadcnColors.accent
                                              : Colors.green.shade600)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cause,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: ThemeController.instance.useShadcn.value
                                  ? ShadcnColors.accent
                                  : Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              // Update the main state with selected causes
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ThemeController.instance.useShadcn.value
                                  ? ShadcnColors.accent
                                  : Colors.green.shade600,
                              fontWeight: FontWeight.w600,
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

  void _showAddChildModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Newborn Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ThemeController.instance.useShadcn.value
                            ? ShadcnColors.accent700
                            : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Row 1: Gender, Weight, Temperature
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          // Gender field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Gender',
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
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Male',
                                      groupValue: _newbornGender,
                                      onChanged: (String? value) {
                                        setModalState(() {
                                          _newbornGender = value;
                                        });
                                      },
                                      activeColor: ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent
                                          : Colors.green.shade600,
                                    ),
                                    const Text('Male'),
                                    const SizedBox(width: 16),
                                    Radio<String>(
                                      value: 'Female',
                                      groupValue: _newbornGender,
                                      onChanged: (String? value) {
                                        setModalState(() {
                                          _newbornGender = value;
                                        });
                                      },
                                      activeColor: ThemeController.instance.useShadcn.value
                                          ? ShadcnColors.accent
                                          : Colors.green.shade600,
                                    ),
                                    const Text('Female'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Weight field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Weight (1-6) (kg)',
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
                                 TextFormField(
                                   controller: _newbornWeightController,
                                   keyboardType: TextInputType.numberWithOptions(decimal: true),
                                   decoration: InputDecoration(
                                     hintText: 'Enter weight',
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
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Temperature field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Temperature (96-106) (°F)',
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
                                 TextFormField(
                                   controller: _newbornTemperatureController,
                                   keyboardType: TextInputType.numberWithOptions(decimal: true),
                                   decoration: InputDecoration(
                                     hintText: 'Enter temperature',
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Row 2: Condition of baby
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Condition of baby',
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
                          const SizedBox(height: 12),
                           Wrap(
                             spacing: 16,
                             children: [
                               Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Radio<String>(
                                     value: 'Alive and Healthy',
                                     groupValue: _newbornCondition,
                                     onChanged: (String? value) {
                                       setModalState(() {
                                         _newbornCondition = value;
                                       });
                                     },
                                     activeColor: ThemeController.instance.useShadcn.value
                                         ? ShadcnColors.accent
                                         : Colors.green.shade600,
                                   ),
                                   const Text('Alive and Healthy'),
                                 ],
                               ),
                               Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Radio<String>(
                                     value: 'Alive and Unhealthy',
                                     groupValue: _newbornCondition,
                                     onChanged: (String? value) {
                                       setModalState(() {
                                         _newbornCondition = value;
                                       });
                                     },
                                     activeColor: ThemeController.instance.useShadcn.value
                                         ? ShadcnColors.accent
                                         : Colors.green.shade600,
                                   ),
                                   const Text('Alive and Unhealthy'),
                                 ],
                               ),
                               Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Radio<String>(
                                     value: 'Dead after delivery',
                                     groupValue: _newbornCondition,
                                     onChanged: (String? value) {
                                       setModalState(() {
                                         _newbornCondition = value;
                                       });
                                     },
                                     activeColor: ThemeController.instance.useShadcn.value
                                         ? ShadcnColors.accent
                                         : Colors.green.shade600,
                                   ),
                                   const Text('Dead after delivery'),
                                 ],
                               ),
                               Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Radio<String>(
                                     value: 'Intrauterine death',
                                     groupValue: _newbornCondition,
                                     onChanged: (String? value) {
                                       setModalState(() {
                                         _newbornCondition = value;
                                       });
                                     },
                                     activeColor: ThemeController.instance.useShadcn.value
                                         ? ShadcnColors.accent
                                         : Colors.green.shade600,
                                   ),
                                   const Text('Intrauterine death'),
                                 ],
                               ),
                             ],
                           ),
                        ],
                      ),
                     ),
                     
                     // Symptoms and Medication fields (only shown when Alive options are selected)
                     if (_newbornCondition == 'Alive and Healthy' || _newbornCondition == 'Alive and Unhealthy') ...[
                       const SizedBox(height: 16),
                       Row(
                         children: [
                           // Symptoms assessment field
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   'Symptoms assessment',
                                   style: TextStyle(
                                     fontSize: 14,
                                     fontWeight: FontWeight.w600,
                                     color: ThemeController.instance.useShadcn.value
                                         ? ShadcnColors.accent700
                                         : Colors.green.shade700,
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 InkWell(
                                   onTap: () => _showNewbornSymptomsModal(),
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(
                                       horizontal: 12,
                                       vertical: 10,
                                     ),
                                     decoration: BoxDecoration(
                                       color: Colors.grey.shade50,
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: Colors.grey.shade300),
                                     ),
                                     child: _selectedNewbornSymptoms.isEmpty
                                         ? Row(
                                             children: [
                                               Expanded(
                                                 child: Text(
                                                   'Select symptoms',
                                                   style: TextStyle(
                                                     color: Colors.grey.shade600,
                                                   ),
                                                 ),
                                               ),
                                               Icon(
                                                 Icons.arrow_drop_down,
                                                 color: Colors.grey.shade600,
                                               ),
                                             ],
                                           )
                                         : Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Wrap(
                                                 spacing: 8,
                                                 runSpacing: 8,
                                                 children: _selectedNewbornSymptoms.map((symptom) {
                                                   return Container(
                                                     padding: const EdgeInsets.symmetric(
                                                       horizontal: 8,
                                                       vertical: 4,
                                                     ),
                                                     decoration: BoxDecoration(
                                                       color: ThemeController.instance.useShadcn.value
                                                           ? ShadcnColors.accent100
                                                           : Colors.green.shade100,
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
                                                         Flexible(
                                                           child: Text(
                                                             symptom,
                                                             style: TextStyle(
                                                               fontSize: 12,
                                                               color: ThemeController.instance.useShadcn.value
                                                                   ? ShadcnColors.accent700
                                                                   : Colors.green.shade700,
                                                               fontWeight: FontWeight.w500,
                                                             ),
                                                             overflow: TextOverflow.ellipsis,
                                                           ),
                                                         ),
                                                         const SizedBox(width: 4),
                                                         GestureDetector(
                                                           onTap: () {
                                                             setModalState(() {
                                                               _selectedNewbornSymptoms.remove(symptom);
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
                                               const SizedBox(height: 8),
                                               Row(
                                                 mainAxisAlignment: MainAxisAlignment.end,
                                                 children: [
                                                   Icon(
                                                     Icons.arrow_drop_down,
                                                     color: Colors.grey.shade600,
                                                   ),
                                                 ],
                                               ),
                                             ],
                                           ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(width: 16),
                           
                           // Medication/vaccines administered field
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   'Medication/vaccines administered',
                                   style: TextStyle(
                                     fontSize: 14,
                                     fontWeight: FontWeight.w600,
                                     color: ThemeController.instance.useShadcn.value
                                         ? ShadcnColors.accent700
                                         : Colors.green.shade700,
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 InkWell(
                                   onTap: () => _showNewbornMedicationsModal(),
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(
                                       horizontal: 12,
                                       vertical: 10,
                                     ),
                                     decoration: BoxDecoration(
                                       color: Colors.grey.shade50,
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: Colors.grey.shade300),
                                     ),
                                     child: _selectedNewbornMedications.isEmpty
                                         ? Row(
                                             children: [
                                               Expanded(
                                                 child: Text(
                                                   'Select medications/vaccines',
                                                   style: TextStyle(
                                                     color: Colors.grey.shade600,
                                                   ),
                                                 ),
                                               ),
                                               Icon(
                                                 Icons.arrow_drop_down,
                                                 color: Colors.grey.shade600,
                                               ),
                                             ],
                                           )
                                         : Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Wrap(
                                                 spacing: 8,
                                                 runSpacing: 8,
                                                 children: _selectedNewbornMedications.map((medication) {
                                                   return Container(
                                                     padding: const EdgeInsets.symmetric(
                                                       horizontal: 8,
                                                       vertical: 4,
                                                     ),
                                                     decoration: BoxDecoration(
                                                       color: ThemeController.instance.useShadcn.value
                                                           ? ShadcnColors.accent100
                                                           : Colors.green.shade100,
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
                                                         Flexible(
                                                           child: Text(
                                                             medication,
                                                             style: TextStyle(
                                                               fontSize: 12,
                                                               color: ThemeController.instance.useShadcn.value
                                                                   ? ShadcnColors.accent700
                                                                   : Colors.green.shade700,
                                                               fontWeight: FontWeight.w500,
                                                             ),
                                                             overflow: TextOverflow.ellipsis,
                                                           ),
                                                         ),
                                                         const SizedBox(width: 4),
                                                         GestureDetector(
                                                           onTap: () {
                                                             setModalState(() {
                                                               _selectedNewbornMedications.remove(medication);
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
                                               const SizedBox(height: 8),
                                               Row(
                                                 mainAxisAlignment: MainAxisAlignment.end,
                                                 children: [
                                                   Icon(
                                                     Icons.arrow_drop_down,
                                                     color: Colors.grey.shade600,
                                                   ),
                                                 ],
                                               ),
                                             ],
                                           ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ],
                     
                     // Cause of Death field (only shown when Dead options are selected)
                     if (_newbornCondition == 'Dead after delivery' || _newbornCondition == 'Intrauterine death') ...[
                       const SizedBox(height: 16),
                       Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           border: Border.all(
                             color: Colors.grey.shade300,
                             width: 1,
                           ),
                           borderRadius: BorderRadius.circular(8),
                           color: Colors.grey.shade50,
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               children: [
                                 Text(
                                   'Cause of Death',
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
                             TextFormField(
                               controller: _newbornCauseOfDeathController,
                               decoration: InputDecoration(
                                 hintText: 'Enter cause of death',
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
                         ),
                       ),
                     ],
                     
                     const SizedBox(height: 24),
                     
                     // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: ThemeController.instance.useShadcn.value
                                  ? ShadcnColors.accent
                                  : Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                         TextButton(
                           onPressed: () {
                             // Validate required fields
                             if (_newbornGender == null) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Please select gender'),
                                   backgroundColor: Colors.red,
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                               return;
                             }
                             
                             if (_newbornWeightController.text.trim().isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Please enter weight'),
                                   backgroundColor: Colors.red,
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                               return;
                             }
                             
                             final weight = double.tryParse(_newbornWeightController.text.trim());
                             if (weight == null || weight < 1 || weight > 6) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Weight must be between 1-6 kg'),
                                   backgroundColor: Colors.red,
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                               return;
                             }
                             
                             if (_newbornTemperatureController.text.trim().isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Please enter temperature'),
                                   backgroundColor: Colors.red,
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                               return;
                             }
                             
                             final temperature = double.tryParse(_newbornTemperatureController.text.trim());
                             if (temperature == null || temperature < 96 || temperature > 106) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Temperature must be between 96-106°F'),
                                   backgroundColor: Colors.red,
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                               return;
                             }
                             
                             if (_newbornCondition == null) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Please select condition of baby'),
                                   backgroundColor: Colors.red,
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                               return;
                             }
                             
                             // Validate cause of death if condition is dead
                             if ((_newbornCondition == 'Dead after delivery' || _newbornCondition == 'Intrauterine death') &&
                                 _newbornCauseOfDeathController.text.trim().isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Please enter cause of death'),
                                   backgroundColor: Colors.red,
                                   behavior: SnackBarBehavior.floating,
                                 ),
                               );
                               return;
                             }
                             
                             // Create child record
                             final childRecord = {
                               'id': DateTime.now().millisecondsSinceEpoch.toString(),
                               'gender': _newbornGender,
                               'weight': _newbornWeightController.text.trim(),
                               'temperature': _newbornTemperatureController.text.trim(),
                               'condition': _newbornCondition,
                               'symptoms': List<String>.from(_selectedNewbornSymptoms),
                               'medications': List<String>.from(_selectedNewbornMedications),
                               'causeOfDeath': _newbornCauseOfDeathController.text.trim(),
                               'timestamp': DateTime.now(),
                             };
                             
                             // Add to records
                             setState(() {
                               _childRecords.add(childRecord);
                             });
                             
                             // Clear form
                             _newbornGender = null;
                             _newbornWeightController.clear();
                             _newbornTemperatureController.clear();
                             _newbornCondition = null;
                             _selectedNewbornSymptoms.clear();
                             _selectedNewbornMedications.clear();
                             _newbornCauseOfDeathController.clear();
                             
                             Navigator.of(context).pop();
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Newborn information saved successfully'),
                                 backgroundColor: Colors.green,
                                 behavior: SnackBarBehavior.floating,
                               ),
                             );
                           },
                          child: Text(
                            'SAVE',
                            style: TextStyle(
                              color: ThemeController.instance.useShadcn.value
                                  ? ShadcnColors.accent
                                  : Colors.green.shade600,
                              fontWeight: FontWeight.w600,
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

   void _showNewbornSymptomsModal() {
     final List<String> newbornSymptoms = [
       'Chest in-drawing, grunting, or moaning',
       'Not breastfeeding well',
       'Fits or convulsions',
       'Poor movement on stimulation',
     ];

     showDialog(
       context: context,
       builder: (BuildContext context) {
         return StatefulBuilder(
           builder: (context, setModalState) {
             return AlertDialog(
               backgroundColor: Colors.white,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(12),
               ),
               contentPadding: const EdgeInsets.all(24),
               content: SizedBox(
                 width: MediaQuery.of(context).size.width * 0.4,
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Symptoms Assessment',
                       style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.w600,
                         color: ThemeController.instance.useShadcn.value
                             ? ShadcnColors.accent700
                             : Colors.green.shade700,
                       ),
                     ),
                     const SizedBox(height: 20),
                     Flexible(
                       child: ListView.builder(
                         shrinkWrap: true,
                         itemCount: newbornSymptoms.length,
                         itemBuilder: (context, index) {
                           final symptom = newbornSymptoms[index];
                           final isSelected = _selectedNewbornSymptoms.contains(symptom);
                           
                           return InkWell(
                             onTap: () {
                               setModalState(() {
                                 if (isSelected) {
                                   _selectedNewbornSymptoms.remove(symptom);
                                 } else {
                                   _selectedNewbornSymptoms.add(symptom);
                                 }
                               });
                             },
                             child: Container(
                               padding: const EdgeInsets.symmetric(vertical: 12),
                               child: Row(
                                 children: [
                                   Container(
                                     width: 20,
                                     height: 20,
                                     decoration: BoxDecoration(
                                       border: Border.all(
                                         color: isSelected
                                             ? (ThemeController.instance.useShadcn.value
                                                 ? ShadcnColors.accent
                                                 : Colors.green.shade600)
                                             : Colors.grey.shade400,
                                         width: 2,
                                       ),
                                       borderRadius: BorderRadius.circular(4),
                                       color: isSelected
                                           ? (ThemeController.instance.useShadcn.value
                                               ? ShadcnColors.accent
                                               : Colors.green.shade600)
                                           : Colors.transparent,
                                     ),
                                     child: isSelected
                                         ? const Icon(
                                             Icons.check,
                                             size: 14,
                                             color: Colors.white,
                                           )
                                         : null,
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Text(
                                       symptom,
                                       style: const TextStyle(
                                         fontSize: 14,
                                         color: Colors.black,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           );
                         },
                       ),
                     ),
                     const SizedBox(height: 24),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         TextButton(
                           onPressed: () {
                             Navigator.of(context).pop();
                           },
                           child: Text(
                             'CANCEL',
                             style: TextStyle(
                               color: ThemeController.instance.useShadcn.value
                                   ? ShadcnColors.accent
                                   : Colors.green.shade600,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ),
                         const SizedBox(width: 16),
                         TextButton(
                           onPressed: () {
                             // Update the main state with selected symptoms
                             setState(() {});
                             Navigator.of(context).pop();
                           },
                           child: Text(
                             'OK',
                             style: TextStyle(
                               color: ThemeController.instance.useShadcn.value
                                   ? ShadcnColors.accent
                                   : Colors.green.shade600,
                               fontWeight: FontWeight.w600,
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

   void _showNewbornMedicationsModal() {
     final List<String> newbornMedications = [
       'Vitamin K injection',
       'Hepatitis B vaccine',
       'BCG vaccine',
       'Polio vaccine',
       'Antibiotics',
       'Other medications',
     ];

     showDialog(
       context: context,
       builder: (BuildContext context) {
         return StatefulBuilder(
           builder: (context, setModalState) {
             return AlertDialog(
               backgroundColor: Colors.white,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(12),
               ),
               contentPadding: const EdgeInsets.all(24),
               content: SizedBox(
                 width: MediaQuery.of(context).size.width * 0.4,
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Medication/Vaccines Administered',
                       style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.w600,
                         color: ThemeController.instance.useShadcn.value
                             ? ShadcnColors.accent700
                             : Colors.green.shade700,
                       ),
                     ),
                     const SizedBox(height: 20),
                     Flexible(
                       child: ListView.builder(
                         shrinkWrap: true,
                         itemCount: newbornMedications.length,
                         itemBuilder: (context, index) {
                           final medication = newbornMedications[index];
                           final isSelected = _selectedNewbornMedications.contains(medication);
                           
                           return InkWell(
                             onTap: () {
                               setModalState(() {
                                 if (isSelected) {
                                   _selectedNewbornMedications.remove(medication);
                                 } else {
                                   _selectedNewbornMedications.add(medication);
                                 }
                               });
                             },
                             child: Container(
                               padding: const EdgeInsets.symmetric(vertical: 12),
                               child: Row(
                                 children: [
                                   Container(
                                     width: 20,
                                     height: 20,
                                     decoration: BoxDecoration(
                                       border: Border.all(
                                         color: isSelected
                                             ? (ThemeController.instance.useShadcn.value
                                                 ? ShadcnColors.accent
                                                 : Colors.green.shade600)
                                             : Colors.grey.shade400,
                                         width: 2,
                                       ),
                                       borderRadius: BorderRadius.circular(4),
                                       color: isSelected
                                           ? (ThemeController.instance.useShadcn.value
                                               ? ShadcnColors.accent
                                               : Colors.green.shade600)
                                           : Colors.transparent,
                                     ),
                                     child: isSelected
                                         ? const Icon(
                                             Icons.check,
                                             size: 14,
                                             color: Colors.white,
                                           )
                                         : null,
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Text(
                                       medication,
                                       style: const TextStyle(
                                         fontSize: 14,
                                         color: Colors.black,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           );
                         },
                       ),
                     ),
                     const SizedBox(height: 24),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         TextButton(
                           onPressed: () {
                             Navigator.of(context).pop();
                           },
                           child: Text(
                             'CANCEL',
                             style: TextStyle(
                               color: ThemeController.instance.useShadcn.value
                                   ? ShadcnColors.accent
                                   : Colors.green.shade600,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ),
                         const SizedBox(width: 16),
                         TextButton(
                           onPressed: () {
                             // Update the main state with selected medications
                             setState(() {});
                             Navigator.of(context).pop();
                           },
                           child: Text(
                             'OK',
                             style: TextStyle(
                               color: ThemeController.instance.useShadcn.value
                                   ? ShadcnColors.accent
                                   : Colors.green.shade600,
                               fontWeight: FontWeight.w600,
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
}
