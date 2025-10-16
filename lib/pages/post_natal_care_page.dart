import 'package:flutter/material.dart';
import '../models/patient_data.dart';
import '../theme/shadcn_colors.dart';
import '../widgets/side_navigation_drawer.dart';
import '../widgets/square_tab.dart';
import '../theme/theme_controller.dart';
import 'patient_selection_page.dart';
import 'pregnancy_dashboard.dart';
import '../models/user_type.dart';

class PostNatalCarePage extends StatefulWidget {
  const PostNatalCarePage({super.key});

  @override
  State<PostNatalCarePage> createState() => _PostNatalCarePageState();
}

class _PostNatalCarePageState extends State<PostNatalCarePage> {
  late VoidCallback _patientListener;
  int _currentTabIndex = 0;
  final GlobalKey _tabWidgetKey = GlobalKey();
  
  // Tab completion status
  List<bool> _tabCompleted = [true, false, false]; // First tab enabled by default
  
  // Vitals And Assessment Controllers
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _hbController = TextEditingController();
  final TextEditingController _bsrController = TextEditingController();
  final TextEditingController _dangerSignsController = TextEditingController();
  
  // Breastfeeding Controllers
  final TextEditingController _breastfeedingNotesController = TextEditingController();
  final TextEditingController _feedingFrequencyController = TextEditingController();
  final TextEditingController _latchingIssuesController = TextEditingController();
  
  // Post-Partum FP Controllers
  // (No controllers needed for radio button fields)
  
  // State Variables
  String? _breastfeedingStatus;
  
  // Breastfeeding specific fields
  String? _breastfeedingCounseling;
  String? _earlyBreastfeedingInitiated;
  String? _firstFeedGiven;
  String? _breastfeedingIssues;
  
  // Post-Partum FP specific fields
  String? _fpCounselingProvided;
  String? _fpCommoditiesGiven;
  bool _showCommoditiesSection = false;
  List<Map<String, dynamic>> _commodities = [];

  final List<String> tabNames = [
    'Vitals And Assessment',
    'Breastfeeding',
    'Post-Partum FP'
  ];

  @override
  void initState() {
    super.initState();
    
    _patientListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    PatientManager.addListener(_patientListener);
  }

  @override
  void dispose() {
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _hbController.dispose();
    _bsrController.dispose();
    _dangerSignsController.dispose();
    _breastfeedingNotesController.dispose();
    _feedingFrequencyController.dispose();
    _latchingIssuesController.dispose();
    PatientManager.removeListener(_patientListener);
    super.dispose();
  }

  String _getNextTabName() {
    final nextIndex = _currentTabIndex + 1;
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
        // Programmatically switch to the previous tab
        (_tabWidgetKey.currentState as dynamic)?.animateToTab(_currentTabIndex);
      });
    }
  }

  void _cancel() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PregnancyDashboard(),
      ),
    );
  }


  void _resetCurrentTab() {
    setState(() {
      switch (_currentTabIndex) {
        case 0: // Vitals And Assessment
          _bpSystolicController.clear();
          _bpDiastolicController.clear();
          _temperatureController.clear();
          _pulseController.clear();
          _hbController.clear();
          _bsrController.clear();
          _dangerSignsController.clear();
          break;
        case 1: // Breastfeeding
          _breastfeedingStatus = null;
          _breastfeedingNotesController.clear();
          _feedingFrequencyController.clear();
          _latchingIssuesController.clear();
          _breastfeedingCounseling = null;
          _earlyBreastfeedingInitiated = null;
          _firstFeedGiven = null;
          _breastfeedingIssues = null;
          break;
        case 2: // Post-Partum FP
          _fpCounselingProvided = null;
          _fpCommoditiesGiven = null;
          _showCommoditiesSection = false;
          _commodities.clear();
          break;
      }
    });
  }

  void _saveAndContinue() {
    // Mark current tab as completed
    setState(() {
      _tabCompleted[_currentTabIndex] = true;
      
      // Move to next tab if available
      if (_currentTabIndex < tabNames.length - 1) {
        _currentTabIndex = _currentTabIndex + 1;
        // Enable the next tab before switching
        _tabCompleted[_currentTabIndex] = true;
        // Programmatically switch to the next tab
        (_tabWidgetKey.currentState as dynamic)?.animateToTab(_currentTabIndex);
      }
    });
    
    // Show success message for last tab
    if (_currentTabIndex >= tabNames.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post Natal Care completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeController.instance.useShadcn.value
          ? Colors.grey.shade50
          : Colors.green.shade50,
      body: SideNavigationDrawer(
        currentRoute: '/post-natal-care',
        userType: 'Doctor',
        child: Column(
          children: [
            // Selected patient (compact) - matching other pregnancy sections
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
            
            // Main content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Tab navigation
                    Expanded(
                      child: SquareTabWidget(
                        key: _tabWidgetKey,
                        tabs: tabNames,
                        children: [
                          _buildVitalsAndAssessmentTab(),
                          _buildBreastfeedingTab(),
                          _buildPostPartumFPTab(),
                        ],
                        initialIndex: _currentTabIndex,
                        tabEnabled: _tabCompleted,
                        onTabChanged: (index) {
                          setState(() {
                            _currentTabIndex = index;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _currentTabIndex > 0 ? _goBack : _cancel,
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
                        onPressed: _resetCurrentTab,
                        child: const Text('Reset'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _saveAndContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: ThemeController.instance.useShadcn.value
                              ? ShadcnColors.accent600
                              : Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_currentTabIndex < tabNames.length - 1 
                            ? 'Save and Continue to ${_getNextTabName()}'
                            : 'Complete Post Natal Care'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsAndAssessmentTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vitals And Assessment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade800,
              ),
            ),
            Text(
              'وٹلز اور تشخیص',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            
            // Blood Pressure Row
            Row(
              children: [
                Expanded(
                  child: _buildNumberField('BP Systolic (50-250)*', '100', _bpSystolicController),
                ),
                const SizedBox(width: 8),
                const Text('/', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberField('BP Diastolic (30-200)*', '80', _bpDiastolicController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Temperature and Pulse Row
            Row(
              children: [
                Expanded(
                  child: _buildNumberField('Temperature (96-106) (°F)*', '100', _temperatureController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField('Pulse (60-100) (bpm)', '56', _pulseController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Hemoglobin and Blood Sugar Row
            Row(
              children: [
                Expanded(
                  child: _buildNumberField('HB (g/dl)*', '12', _hbController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField('BSR (mg/dl)*', '130', _bsrController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Danger Signs
            _buildTextAreaField('Danger Signs', 'Enter any danger signs observed', _dangerSignsController),
          ],
        ),
      ),
    );
  }

  Widget _buildBreastfeedingTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breastfeeding',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade800,
              ),
            ),
            Text(
              'دودھ پلانا',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            
            // Question 1: Did you counsel the patient on breastfeeding?
            _buildRadioButtonField('Did you counsel the patient on breastfeeding? *', _breastfeedingCounseling, [
              'Yes',
              'No',
            ], (value) {
              setState(() {
                _breastfeedingCounseling = value;
              });
            }),
            const SizedBox(height: 16),
            
            // Question 2: Did the mother initiate early Breastfeeding?
            _buildRadioButtonField('Did the mother initiate early Breastfeeding? *', _earlyBreastfeedingInitiated, [
              'Yes',
              'No',
            ], (value) {
              setState(() {
                _earlyBreastfeedingInitiated = value;
              });
            }),
            const SizedBox(height: 16),
            
            // Question 3: What was the first feed given to child?
            _buildDropdownField('What was the first feed given to child? *', 'Select First Feed Given', _firstFeedGiven, [
              'Breast Milk',
              'Formula',
              'Water',
              'Honey',
              'Other',
            ], (value) {
              setState(() {
                _firstFeedGiven = value;
              });
            }),
            const SizedBox(height: 16),
            
            // Question 4: Did the patient report any issue with breastfeeding?
            _buildRadioButtonField('Did the patient report any issue with breastfeeding? *', _breastfeedingIssues, [
              'Yes',
              'No',
            ], (value) {
              setState(() {
                _breastfeedingIssues = value;
              });
            }),
            const SizedBox(height: 16),
            
            // Additional fields for detailed information
            _buildDropdownField('Breastfeeding Status', 'Select breastfeeding status', _breastfeedingStatus, [
              'Exclusive Breastfeeding',
              'Mixed Feeding',
              'Formula Only',
              'Not Feeding',
            ], (value) {
              setState(() {
                _breastfeedingStatus = value;
              });
            }),
            const SizedBox(height: 16),
            
            _buildTextField('Feeding Frequency', 'How often is the baby feeding?', _feedingFrequencyController),
            const SizedBox(height: 16),
            
            _buildTextAreaField('Latching Issues', 'Describe any latching or feeding issues', _latchingIssuesController),
            const SizedBox(height: 16),
            
            _buildTextAreaField('Breastfeeding Notes', 'Additional breastfeeding observations and notes', _breastfeedingNotesController),
          ],
        ),
      ),
    );
  }

  Widget _buildPostPartumFPTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post-Partum FP',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade800,
              ),
            ),
            Text(
              'بعد از پیدائش خاندانی منصوبہ بندی',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            
            // Question 1: Did you counsel the patient on family planning?
            _buildRadioButtonField('Did you counsel the patient on family planning? *', _fpCounselingProvided, [
              'Yes',
              'No',
            ], (value) {
              setState(() {
                _fpCounselingProvided = value;
              });
            }),
            const SizedBox(height: 16),
            
            // Question 2: FP commodities given?
            _buildRadioButtonField('FP commodities given? *', _fpCommoditiesGiven, [
              'Yes',
              'No',
            ], (value) {
              setState(() {
                _fpCommoditiesGiven = value;
                _showCommoditiesSection = value == 'Yes';
                if (value == 'No') {
                  _commodities.clear();
                }
              });
            }),
            
            // Commodities Section (only show if Yes is selected)
            if (_showCommoditiesSection) ...[
              const SizedBox(height: 16),
              _buildCommoditiesSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommoditiesSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent50
                  : Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FP Commodities',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeController.instance.useShadcn.value
                        ? ShadcnColors.accent700
                        : Colors.green.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddCommodityModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Commodity'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeController.instance.useShadcn.value
                        ? ShadcnColors.accent500
                        : Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_commodities.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No commodities added yet. Click "Add Commodity" to get started.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._commodities.map((commodity) {
                    final index = _commodities.indexOf(commodity);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commodity['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: ${commodity['quantity'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeCommodity(index),
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade600,
                              size: 24,
                            ),
                            tooltip: 'Remove commodity',
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCommodityModal() {
    String? selectedCommodity;
    final TextEditingController quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add FP Commodity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commodity Type *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCommodity,
                decoration: InputDecoration(
                  hintText: 'Select commodity type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  'Condoms',
                  'IUCD (Intrauterine Contraceptive Device)',
                  'Oral Contraceptive Pills',
                  'Injectable Contraceptives',
                  'Implant',
                  'Emergency Contraceptive Pills',
                  'Diaphragm',
                  'Cervical Cap',
                  'Spermicide',
                  'Other',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedCommodity = newValue;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Quantity *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCommodity != null && quantityController.text.trim().isNotEmpty) {
                  setState(() {
                    _commodities.add({
                      'name': selectedCommodity!,
                      'quantity': quantityController.text.trim(),
                    });
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a commodity and enter quantity'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent600
                    : Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeCommodity(int index) {
    setState(() {
      _commodities.removeAt(index);
    });
  }

  Widget _buildNumberField(String label, String hint, TextEditingController controller) {
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
                : Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent500
                    : Colors.green.shade600,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
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
                : Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent500
                    : Colors.green.shade600,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(String label, String hint, TextEditingController controller) {
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
                : Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent500
                    : Colors.green.shade600,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
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
                : Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent500
                    : Colors.green.shade600,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioButtonField(String label, String? selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((option) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                  activeColor: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent500
                      : Colors.green.shade600,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
