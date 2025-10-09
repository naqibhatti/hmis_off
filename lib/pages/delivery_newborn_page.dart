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
  List<bool> _tabCompleted = [false, false, false];
  
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
                Text(
                  'Initial Assessment',
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
                          Icons.assessment_outlined,
                          size: 64,
                          color: ShadcnColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Initial Assessment Form',
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
                onPressed: _resetInitialAssessmentFields,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveAndContinueInitialAssessment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShadcnColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Save and Continue to ${_getNextTabName()}'),
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
                onPressed: _resetDeliveryAssessmentFields,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveAndContinueDeliveryAssessment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShadcnColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Save and Continue to ${_getNextTabName()}'),
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
                onPressed: _resetDischargeReferralsFields,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveAndContinueDischargeReferrals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShadcnColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save and Complete'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Reset methods
  void _resetInitialAssessmentFields() {
    // TODO: Implement reset logic for Initial Assessment
    setState(() {});
  }

  void _resetDeliveryAssessmentFields() {
    // TODO: Implement reset logic for Delivery Assessment
    setState(() {});
  }

  void _resetDischargeReferralsFields() {
    // TODO: Implement reset logic for Discharge & Referrals
    setState(() {});
  }

  // Save and continue methods
  void _saveAndContinueInitialAssessment() {
    // TODO: Implement validation and save logic for Initial Assessment
    setState(() {
      _tabCompleted[0] = true;
      if (_currentTabIndex < tabNames.length - 1) {
        _currentTabIndex++;
        _tabController.animateTo(_currentTabIndex);
      }
    });
  }

  void _saveAndContinueDeliveryAssessment() {
    // TODO: Implement validation and save logic for Delivery Assessment
    setState(() {
      _tabCompleted[1] = true;
      if (_currentTabIndex < tabNames.length - 1) {
        _currentTabIndex++;
        _tabController.animateTo(_currentTabIndex);
      }
    });
  }

  void _saveAndContinueDischargeReferrals() {
    // TODO: Implement validation and save logic for Discharge & Referrals
    setState(() {
      _tabCompleted[2] = true;
    });
    
    // Navigate back to Pregnancy Dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PregnancyDashboard(),
      ),
    );
  }
}
