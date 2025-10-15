import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/patient_data.dart';
import '../services/patient_data_service.dart';
import '../theme/shadcn_colors.dart';
import '../theme/theme_controller.dart';
import '../widgets/side_navigation_drawer.dart';
import 'patient_selection_page.dart';
import '../models/user_type.dart';

class PregnancyRegistrationPage extends StatefulWidget {
  const PregnancyRegistrationPage({super.key});

  @override
  State<PregnancyRegistrationPage> createState() => _PregnancyRegistrationPageState();
}

class _PregnancyRegistrationPageState extends State<PregnancyRegistrationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Date controllers for pregnancy details
  final TextEditingController _lmpController = TextEditingController();
  final TextEditingController _eddController = TextEditingController();
  final TextEditingController _gravidaController = TextEditingController();
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _pretermController = TextEditingController();
  final TextEditingController _previousAbortionsController = TextEditingController();
  final TextEditingController _livingChildrenController = TextEditingController();
  final TextEditingController _numberOfBoysController = TextEditingController();
  final TextEditingController _numberOfGirlsController = TextEditingController();
  
  // Husband information fields
  final TextEditingController _husbandNameController = TextEditingController();
  final TextEditingController _husbandCnicController = TextEditingController();
  final TextEditingController _yearsMarriedController = TextEditingController();
  
  // Consanguineous marriage
  String? _consanguineousMarriage;
  
  // Pregnancy history section
  List<Map<String, dynamic>> _pregnancyHistory = [];
  
  // Controllers for other tabs
  // Diabetes section
  bool _diabetesChecked = false;
  String? _diabetesType;
  String? _diabetesSeverity;
  final TextEditingController _diabetesDiagnosedDateController = TextEditingController();
  
  // Heart Disease section
  bool _heartDiseaseChecked = false;
  String? _heartConditionType;
  String? _heartSeverity;
  final TextEditingController _heartDiagnosedDateController = TextEditingController();
  
  // Hypertension section
  bool _hypertensionChecked = false;
  String? _hypertensionStage;
  final TextEditingController _hypertensionDiagnosedDateController = TextEditingController();
  
  // Stroke section
  bool _strokeChecked = false;
  String? _strokeType;
  String? _strokeDisabilityLevel;
  final TextEditingController _strokeDiagnosedDateController = TextEditingController();
  
  // Cancer section
  bool _cancerChecked = false;
  String? _cancerType;
  String? _cancerTreatmentStatus;
  final TextEditingController _cancerDiagnosedDateController = TextEditingController();
  
  // Asthma section
  bool _asthmaChecked = false;
  String? _asthmaSeverity;
  final TextEditingController _asthmaDiagnosedDateController = TextEditingController();
  
  // IBD section
  bool _ibdChecked = false;
  String? _ibdType;
  String? _ibdSeverity;
  final TextEditingController _ibdDiagnosedDateController = TextEditingController();
  
  // Previous Surgery section
  final TextEditingController _surgeryDescriptionController = TextEditingController();
  bool _surgeryToggle = false;
  
  // Allergies section
  List<Map<String, dynamic>> _allergies = [];
  
  
  // Lifestyle information
  bool _smokingToggle = false;
  bool _alcoholToggle = false;
  final TextEditingController _exerciseHabitsController = TextEditingController();
  final TextEditingController _dietaryPlanController = TextEditingController();
  
  final TextEditingController _clinicalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    // Add listeners for real-time calculation
    _termController.addListener(_updateParaCalculation);
    _pretermController.addListener(_updateParaCalculation);
    _gravidaController.addListener(_updateAbortionsCalculation);
    _gravidaController.addListener(_updatePregnancyHistory);
    _numberOfBoysController.addListener(_updateLivingChildrenCalculation);
    _numberOfGirlsController.addListener(_updateLivingChildrenCalculation);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lmpController.dispose();
    _eddController.dispose();
    _gravidaController.dispose();
    _termController.dispose();
    _pretermController.dispose();
    _previousAbortionsController.dispose();
    _livingChildrenController.dispose();
    _numberOfBoysController.dispose();
    _numberOfGirlsController.dispose();
    _husbandNameController.dispose();
    _husbandCnicController.dispose();
    _yearsMarriedController.dispose();
    _diabetesDiagnosedDateController.dispose();
    _heartDiagnosedDateController.dispose();
    _hypertensionDiagnosedDateController.dispose();
    _strokeDiagnosedDateController.dispose();
    _cancerDiagnosedDateController.dispose();
    _asthmaDiagnosedDateController.dispose();
    _ibdDiagnosedDateController.dispose();
    _surgeryDescriptionController.dispose();
    // Dispose allergy controllers
    for (var allergy in _allergies) {
      allergy['controller']?.dispose();
    }
    // Dispose pregnancy history controllers
    for (var pregnancy in _pregnancyHistory) {
      pregnancy['dateOfDeliveryController']?.dispose();
      pregnancy['weeksOfGestationController']?.dispose();
    }
    _exerciseHabitsController.dispose();
    _dietaryPlanController.dispose();
    _clinicalNotesController.dispose();
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
        currentRoute: '/pregnancy-registration',
        userType: 'Doctor',
        child: Column(
          children: [
            // Selected patient (compact) - copied from ANC
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
                                  builder: (_) => PatientSelectionPage(userType: UserType.doctor),
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
                                builder: (_) => PatientSelectionPage(userType: UserType.doctor),
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
            // Custom tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTabButton('Pregnancy Details', 0),
                  _buildTabButton('Chronic Conditions', 1),
                  _buildTabButton('Previous Surgery', 2),
                  _buildTabButton('Allergies', 3),
                  _buildTabButton('Generic Info', 4),
                  _buildTabButton('Clinical Notes', 5),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab content
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPregnancyDetailsTab(),
                          _buildChronicConditionsTab(),
                          _buildPreviousSurgeryTab(),
                          _buildAllergiesTab(),
                          _buildGenericInfoTab(),
                          _buildClinicalNotesTab(),
                        ],
                      ),
                    ),
                    // Action Buttons - copied from ANC
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
                                onPressed: () {
                                  _resetCurrentTab();
                                },
                                child: const Text('Reset'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: FilledButton(
                                onPressed: () {
                                  _saveAndContinue();
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: ShadcnColors.accent600,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Save and Continue'),
                              ),
                            ),
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
    );
  }

  Widget _buildTabButton(String title, int index) {
    final bool isSelected = _currentTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                  ? (ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent700
                      : Colors.green.shade800)
                  : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildPregnancyDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregnancy Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          Text(
            'حمل کی تفصیلات',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildFormSection([
            // LMP and EDD on the same line
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Last Menstrual Period (LMP)', 'Select LMP date', _lmpController, onDateSelected: _calculateEDD),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField('Expected Due Date (EDD)', 'Auto-calculated from LMP', _eddController, isReadOnly: true),
                ),
              ],
            ),
             _buildTextField('Gravida', 'Number of pregnancies', _gravidaController),
             // Dynamic pregnancy history section
             if (_shouldShowPregnancyHistory()) ...[
               const SizedBox(height: 16),
               _buildPregnancyHistorySection(),
             ],
            // Para section with term and pre-term fields
            Text(
              'Para (Live Births)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            // Term and Pre-term fields on the same line
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Term', 'Full-term pregnancies (≥37 weeks)', _termController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Pre-term', 'Pre-term pregnancies (<37 weeks)', _pretermController),
                ),
              ],
            ),
            // Calculation box
            _buildCalculationBox(),
            _buildReadOnlyField('Previous Abortions', 'Auto-calculated: Gravida - Para', _previousAbortionsController),
            // Living Children section
            Text(
              'Living Children',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            // Living Children fields on the same line
            Row(
              children: [
                Expanded(
                  child: _buildReadOnlyField('Living Children *', 'Auto-calculated total', _livingChildrenController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Number of Boys', 'Enter number of boys', _numberOfBoysController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Number of Girls', 'Enter number of girls', _numberOfGirlsController),
                ),
              ],
            ),
            // Husband Information Section
            const SizedBox(height: 24),
            Text(
              'Husband Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent700
                    : Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Husband Name', 'Enter husband\'s full name', _husbandNameController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCnicField('Husband CNIC', 'Enter 13-digit CNIC (e.g., 12345-1234567-1)', _husbandCnicController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Years Since Married', 'Enter number of years', _yearsMarriedController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField('Consanguineous Marriage (Cousin Marriage)', 'Select Yes or No', _consanguineousMarriage, [
                    'Yes',
                    'No',
                  ], (value) {
                    setState(() {
                      _consanguineousMarriage = value;
                    });
                  }),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildChronicConditionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chronic Conditions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          Text(
            'دائمی بیماریاں',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildChronicConditionSection('Diabetes', _diabetesChecked, (value) {
            setState(() {
              _diabetesChecked = value;
            });
          }, [
            _buildDropdownField('Diabetes Type', 'Select type', _diabetesType, [
              'Type 1 Diabetes',
              'Type 2 Diabetes',
              'Gestational Diabetes',
              'Prediabetes',
            ], (value) {
              setState(() {
                _diabetesType = value;
              });
            }),
            _buildDropdownField('Severity', 'Select severity', _diabetesSeverity, [
              'Mild',
              'Moderate',
              'Severe',
            ], (value) {
              setState(() {
                _diabetesSeverity = value;
              });
            }),
            _buildDateField('Diagnosed Date', 'dd/mm/yyyy', _diabetesDiagnosedDateController),
          ]),
          _buildChronicConditionSection('Heart Disease', _heartDiseaseChecked, (value) {
            setState(() {
              _heartDiseaseChecked = value;
            });
          }, [
            _buildDropdownField('Heart Condition Type', 'Select type', _heartConditionType, [
              'Coronary Artery Disease',
              'Heart Failure',
              'Arrhythmia',
              'Valvular Heart Disease',
              'Cardiomyopathy',
            ], (value) {
              setState(() {
                _heartConditionType = value;
              });
            }),
            _buildDropdownField('Severity', 'Select severity', _heartSeverity, [
              'Mild',
              'Moderate',
              'Severe',
            ], (value) {
              setState(() {
                _heartSeverity = value;
              });
            }),
            _buildDateField('Diagnosed Date', 'dd/mm/yyyy', _heartDiagnosedDateController),
          ]),
          _buildChronicConditionSection('Hypertension', _hypertensionChecked, (value) {
            setState(() {
              _hypertensionChecked = value;
            });
          }, [
            _buildDropdownField('Hypertension Stage', 'Select stage', _hypertensionStage, [
              'Stage 1',
              'Stage 2',
              'Hypertensive Crisis',
            ], (value) {
              setState(() {
                _hypertensionStage = value;
              });
            }),
            _buildDateField('Diagnosed Date', 'dd/mm/yyyy', _hypertensionDiagnosedDateController),
          ]),
          _buildChronicConditionSection('Stroke', _strokeChecked, (value) {
            setState(() {
              _strokeChecked = value;
            });
          }, [
            _buildDropdownField('Stroke Type', 'Select type', _strokeType, [
              'Ischemic Stroke',
              'Hemorrhagic Stroke',
              'Transient Ischemic Attack (TIA)',
            ], (value) {
              setState(() {
                _strokeType = value;
              });
            }),
            _buildDropdownField('Disability Level', 'Select disability level', _strokeDisabilityLevel, [
              'No Disability',
              'Mild Disability',
              'Moderate Disability',
              'Severe Disability',
            ], (value) {
              setState(() {
                _strokeDisabilityLevel = value;
              });
            }),
            _buildDateField('Diagnosed Date', 'dd/mm/yyyy', _strokeDiagnosedDateController),
          ]),
          _buildChronicConditionSection('Cancer', _cancerChecked, (value) {
            setState(() {
              _cancerChecked = value;
            });
          }, [
            _buildDropdownField('Cancer Type', 'Select type', _cancerType, [
              'Breast Cancer',
              'Lung Cancer',
              'Colorectal Cancer',
              'Prostate Cancer',
              'Skin Cancer',
              'Other',
            ], (value) {
              setState(() {
                _cancerType = value;
              });
            }),
            _buildDropdownField('Treatment Status', 'Select treatment status', _cancerTreatmentStatus, [
              'Active Treatment',
              'Completed Treatment',
              'Monitoring',
              'Palliative Care',
            ], (value) {
              setState(() {
                _cancerTreatmentStatus = value;
              });
            }),
            _buildDateField('Diagnosed Date', 'dd/mm/yyyy', _cancerDiagnosedDateController),
          ]),
          _buildChronicConditionSection('Asthma', _asthmaChecked, (value) {
            setState(() {
              _asthmaChecked = value;
            });
          }, [
            _buildDropdownField('Severity', 'Select severity', _asthmaSeverity, [
              'Mild Intermittent',
              'Mild Persistent',
              'Moderate Persistent',
              'Severe Persistent',
            ], (value) {
              setState(() {
                _asthmaSeverity = value;
              });
            }),
            _buildDateField('Diagnosed Date', 'dd/mm/yyyy', _asthmaDiagnosedDateController),
          ]),
          _buildChronicConditionSection('IBD (Inflammatory Bowel Disease)', _ibdChecked, (value) {
            setState(() {
              _ibdChecked = value;
            });
          }, [
            _buildDropdownField('IBD Type', 'Select type', _ibdType, [
              'Crohn\'s Disease',
              'Ulcerative Colitis',
              'Indeterminate Colitis',
            ], (value) {
              setState(() {
                _ibdType = value;
              });
            }),
            _buildDropdownField('Severity', 'Select severity', _ibdSeverity, [
              'Mild',
              'Moderate',
              'Severe',
            ], (value) {
              setState(() {
                _ibdSeverity = value;
              });
            }),
            _buildDateField('Diagnosed Date', 'dd/mm/yyyy', _ibdDiagnosedDateController),
          ]),
        ],
      ),
    );
  }

  Widget _buildPreviousSurgeryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previous Surgery',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          Text(
            'پچھلی سرجری',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildToggleField('Previous Caesarean Section', 'Toggle previous caesarean section', _surgeryToggle, (value) {
            setState(() {
              _surgeryToggle = value;
            });
          }),
          if (_surgeryToggle) ...[
            const SizedBox(height: 16),
            _buildFormSection([
              _buildTextField('Surgery Description', 'Enter details of previous surgeries', _surgeryDescriptionController),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildAllergiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and Add Allergy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Allergies',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent700
                      : Colors.green.shade800,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addAllergy,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Allergy'),
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
          Text(
            'الرجی',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          // Allergy entries
          if (_allergies.isNotEmpty) ...[
            ..._allergies.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> allergy = entry.value;
              return _buildAllergyEntry(index + 1, allergy);
            }).toList(),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  'No allergies added yet. Click "Add Allergy" to get started.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenericInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generic Info',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          Text(
            'عمومی معلومات',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildFormSection([
            _buildLifestyleToggleField('Smoking', 'Check if patient smokes', _smokingToggle, (value) {
              setState(() {
                _smokingToggle = value;
              });
            }),
            _buildLifestyleToggleField('Alcohol Consumption', 'Check if patient consumes alcohol', _alcoholToggle, (value) {
              setState(() {
                _alcoholToggle = value;
              });
            }),
            _buildTextAreaField('Exercise Habits', 'Describe exercise routine and physical activity', _exerciseHabitsController),
            _buildTextAreaField('Dietary Plan', 'Describe dietary patterns, restrictions, or special diet', _dietaryPlanController),
          ]),
        ],
      ),
    );
  }

  Widget _buildClinicalNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinical Notes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          Text(
            'کلینیکل نوٹس',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextAreaField('Clinical Notes', 'Enter notes, observations, and special instructions', _clinicalNotesController),
        ],
      ),
    );
  }

  Widget _buildFormSection(List<Widget> fields) {
    return Column(
      children: fields.map((field) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: field,
      )).toList(),
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

  Widget _buildCnicField(String label, String hint, TextEditingController controller) {
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
          maxLength: 15, // 13 digits + 2 dashes
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
            _CnicInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: hint,
            counterText: '', // Hide character counter
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

  Widget _buildReadOnlyField(String label, String hint, TextEditingController controller) {
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
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
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
                color: Colors.grey.shade400,
                width: 1,
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

  Widget _buildChronicConditionSection(String title, bool isChecked, ValueChanged<bool> onChanged, List<Widget> fields) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with checkbox
          Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (value) => onChanged(value ?? false),
                activeColor: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent500
                    : Colors.green.shade600,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent700
                      : Colors.green.shade800,
                ),
              ),
            ],
          ),
          // Fields - arranged horizontally when possible
          if (isChecked) ...[
            const SizedBox(height: 12),
            if (fields.length == 2)
              Row(
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 16),
                  Expanded(child: fields[1]),
                ],
              )
            else if (fields.length == 3)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: fields[0]),
                      const SizedBox(width: 16),
                      Expanded(child: fields[1]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  fields[2],
                ],
              )
            else
              Column(
                children: fields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: field,
                )).toList(),
              ),
          ],
        ],
      ),
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

  Widget _buildToggleField(String label, String hint, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ThemeController.instance.useShadcn.value
              ? ShadcnColors.accent500
              : Colors.green.shade600,
        ),
      ],
    );
  }

  Widget _buildLifestyleToggleField(String label, String hint, bool value, ValueChanged<bool> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ThemeController.instance.useShadcn.value
                ? ShadcnColors.accent700
                : Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent500
                  : Colors.green.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
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

  Widget _buildDateField(String label, String hint, TextEditingController controller, {bool isReadOnly = false, Function(DateTime)? onDateSelected}) {
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
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: isReadOnly ? null : Icon(
              Icons.calendar_today,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent500
                  : Colors.green.shade600,
            ),
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
          onTap: isReadOnly ? null : () => _selectDate(context, controller, onDateSelected),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime)? onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // 2 years ago
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent500
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
      final String formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      controller.text = formattedDate;
      
      if (onDateSelected != null) {
        onDateSelected(picked);
      }
    }
  }

  void _calculateEDD(DateTime lmpDate) {
    // EDD is calculated as 280 days (40 weeks) after LMP
    final DateTime eddDate = lmpDate.add(const Duration(days: 280));
    final String formattedEDD = "${eddDate.day.toString().padLeft(2, '0')}/${eddDate.month.toString().padLeft(2, '0')}/${eddDate.year}";
    _eddController.text = formattedEDD;
  }

  void _updateParaCalculation() {
    setState(() {
      // This will trigger a rebuild and update the calculation box
    });
    _calculateAbortions();
  }

  void _updateAbortionsCalculation() {
    setState(() {
      // This will trigger a rebuild and update the abortion calculation
    });
    _calculateAbortions();
  }

  void _calculateAbortions() {
    final int gravida = int.tryParse(_gravidaController.text) ?? 0;
    final int term = int.tryParse(_termController.text) ?? 0;
    final int preterm = int.tryParse(_pretermController.text) ?? 0;
    final int para = term + preterm;
    final int abortions = gravida - para;
    
    _previousAbortionsController.text = abortions.toString();
  }

  void _updateLivingChildrenCalculation() {
    setState(() {
      // This will trigger a rebuild and update the living children calculation
    });
    _calculateLivingChildren();
  }

  void _calculateLivingChildren() {
    final int boys = int.tryParse(_numberOfBoysController.text) ?? 0;
    final int girls = int.tryParse(_numberOfGirlsController.text) ?? 0;
    final int total = boys + girls;
    
    _livingChildrenController.text = total.toString();
  }

  bool _shouldShowPregnancyHistory() {
    final int gravida = int.tryParse(_gravidaController.text) ?? 0;
    return gravida > 1;
  }

  void _updatePregnancyHistory() {
    final int gravida = int.tryParse(_gravidaController.text) ?? 0;
    setState(() {
      if (gravida > 1) {
        // Add new pregnancy entries if needed
        while (_pregnancyHistory.length < gravida - 1) {
          _pregnancyHistory.add({
            'dateOfDeliveryController': TextEditingController(),
            'weeksOfGestationController': TextEditingController(),
            'modeOfDelivery': null,
            'typeOfAnesthesia': null,
            'abortionType': null,
            'dncPerformed': null,
            'stillAlive': null,
            'complications': null,
          });
        }
        // Remove excess entries if gravida decreased
        while (_pregnancyHistory.length > gravida - 1) {
          final removed = _pregnancyHistory.removeLast();
          removed['dateOfDeliveryController']?.dispose();
          removed['weeksOfGestationController']?.dispose();
        }
      } else {
        // Clear all pregnancy history if gravida is 1 or less
        for (var pregnancy in _pregnancyHistory) {
          pregnancy['dateOfDeliveryController']?.dispose();
          pregnancy['weeksOfGestationController']?.dispose();
        }
        _pregnancyHistory.clear();
      }
    });
  }

  Widget _buildPregnancyHistorySection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previous Pregnancy History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Text(
            'پچھلی حمل کی تاریخ',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          ..._pregnancyHistory.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> pregnancy = entry.value;
            return _buildPregnancyHistoryEntry(index + 1, pregnancy);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPregnancyHistoryEntry(int number, Map<String, dynamic> pregnancy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregnancy #$number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          // First row: Date of Delivery and Weeks of Gestation
          Row(
            children: [
              Expanded(
                child: _buildDateField('Date of Delivery', 'dd/mm/yyyy', pregnancy['dateOfDeliveryController']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Weeks of Gestation', 'Enter weeks', pregnancy['weeksOfGestationController']),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Second row: Mode of Delivery and Type of Anesthesia
          Row(
            children: [
              Expanded(
                child: _buildDropdownField('Mode of Delivery', 'Select mode', pregnancy['modeOfDelivery'], [
                  'SVD',
                  'Cesarean',
                ], (value) {
                  setState(() {
                    pregnancy['modeOfDelivery'] = value;
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField('Type of Anesthesia', 'Select type', pregnancy['typeOfAnesthesia'], [
                  'General',
                  'Spinal',
                  'Epidural',
                ], (value) {
                  setState(() {
                    pregnancy['typeOfAnesthesia'] = value;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Third row: Abortion Type and DNC Performed
          Row(
            children: [
              Expanded(
                child: _buildDropdownField('If Aborted/Miscarriage: Type', 'Select type', pregnancy['abortionType'], [
                  'Missed Abortion',
                  'Complete',
                  'Incomplete',
                  'Medically Induced',
                ], (value) {
                  setState(() {
                    pregnancy['abortionType'] = value;
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField('DNC Performed', 'Yes/No', pregnancy['dncPerformed'], [
                  'Yes',
                  'No',
                ], (value) {
                  setState(() {
                    pregnancy['dncPerformed'] = value;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fourth row: Still Alive and Complications
          Row(
            children: [
              Expanded(
                child: _buildDropdownField('Still Alive', 'Yes/No', pregnancy['stillAlive'], [
                  'Yes',
                  'No',
                ], (value) {
                  setState(() {
                    pregnancy['stillAlive'] = value;
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField('Any Complication', 'Select complication', pregnancy['complications'], [
                  'ANC',
                  'PNC',
                  'Peripartal',
                ], (value) {
                  setState(() {
                    pregnancy['complications'] = value;
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goBack() {
    if (_currentTabIndex > 0) {
      _tabController.animateTo(_currentTabIndex - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  String _getPreviousTabName() {
    final List<String> tabNames = [
      'Pregnancy Details',
      'Chronic Conditions',
      'Previous Surgery',
      'Allergies',
      'Generic Info',
      'Clinical Notes',
    ];
    
    if (_currentTabIndex > 0) {
      return tabNames[_currentTabIndex - 1];
    }
    return 'Dashboard';
  }

  void _resetCurrentTab() {
    setState(() {
      switch (_currentTabIndex) {
        case 0: // Pregnancy Details
          setState(() {
            _lmpController.clear();
            _eddController.clear();
            _gravidaController.clear();
            _termController.clear();
            _pretermController.clear();
            _previousAbortionsController.clear();
            _livingChildrenController.clear();
            _numberOfBoysController.clear();
            _numberOfGirlsController.clear();
            _husbandNameController.clear();
            _husbandCnicController.clear();
            _yearsMarriedController.clear();
            _consanguineousMarriage = null;
            // Clear pregnancy history
            for (var pregnancy in _pregnancyHistory) {
              pregnancy['dateOfDeliveryController']?.dispose();
              pregnancy['weeksOfGestationController']?.dispose();
            }
            _pregnancyHistory.clear();
          });
          break;
        case 1: // Chronic Conditions
          setState(() {
            _diabetesChecked = false;
            _diabetesType = null;
            _diabetesSeverity = null;
            _diabetesDiagnosedDateController.clear();
            
            _heartDiseaseChecked = false;
            _heartConditionType = null;
            _heartSeverity = null;
            _heartDiagnosedDateController.clear();
            
            _hypertensionChecked = false;
            _hypertensionStage = null;
            _hypertensionDiagnosedDateController.clear();
            
            _strokeChecked = false;
            _strokeType = null;
            _strokeDisabilityLevel = null;
            _strokeDiagnosedDateController.clear();
            
            _cancerChecked = false;
            _cancerType = null;
            _cancerTreatmentStatus = null;
            _cancerDiagnosedDateController.clear();
            
            _asthmaChecked = false;
            _asthmaSeverity = null;
            _asthmaDiagnosedDateController.clear();
            
            _ibdChecked = false;
            _ibdType = null;
            _ibdSeverity = null;
            _ibdDiagnosedDateController.clear();
          });
          break;
        case 2: // Previous Surgery
          setState(() {
            _surgeryDescriptionController.clear();
            _surgeryToggle = false;
          });
          break;
        case 3: // Allergies
          setState(() {
            // Dispose all allergy controllers
            for (var allergy in _allergies) {
              allergy['controller']?.dispose();
            }
            _allergies.clear();
          });
          break;
        case 4: // Generic Info
          setState(() {
            _smokingToggle = false;
            _alcoholToggle = false;
            _exerciseHabitsController.clear();
            _dietaryPlanController.clear();
          });
          break;
        case 5: // Clinical Notes
          _clinicalNotesController.clear();
          break;
      }
    });
  }

  void _saveAndContinue() {
    if (_currentTabIndex < 5) {
      _tabController.animateTo(_currentTabIndex + 1);
    } else {
      // Last tab - handle form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pregnancy registration completed!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addAllergy() {
    setState(() {
      _allergies.add({
        'controller': TextEditingController(),
        'type': null,
        'severity': null,
      });
    });
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies[index]['controller']?.dispose();
      _allergies.removeAt(index);
    });
  }

  Widget _buildAllergyEntry(int number, Map<String, dynamic> allergy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with allergy number and remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Allergy #$number',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _removeAllergy(number - 1),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Remove allergy',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Three fields in a row
          Row(
            children: [
              Expanded(
                child: _buildTextField('Allergen', 'e.g., Penicillin, Peanuts', allergy['controller']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField('Type', 'Select type', allergy['type'], [
                  'Drug',
                  'Food',
                  'Environmental',
                  'Insect',
                  'Latex',
                  'Other',
                ], (value) {
                  setState(() {
                    allergy['type'] = value;
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField('Severity', 'Select severity', allergy['severity'], [
                  'Mild',
                  'Moderate',
                  'Severe',
                  'Life-threatening',
                ], (value) {
                  setState(() {
                    allergy['severity'] = value;
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationBox() {
    final int term = int.tryParse(_termController.text) ?? 0;
    final int preterm = int.tryParse(_pretermController.text) ?? 0;
    final int total = term + preterm;
    
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregnancy Calculation Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCalculationItem('Term Pregnancies', term.toString()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCalculationItem('Pre-term Pregnancies', preterm.toString()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCalculationItem('Total Live Births', total.toString(), isTotal: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total Live Births = Term + Pre-term Pregnancies',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationItem(String label, String value, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isTotal ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTotal 
              ? (ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent300
                  : Colors.green.shade300)
              : Colors.grey.shade300,
          width: isTotal ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isTotal 
                  ? (ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent700
                      : Colors.green.shade800)
                  : Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 13 digits
    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }
    
    // Format with dashes: XXXXX-XXXXXXX-X
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 5) {
        formatted += '-';
      } else if (i == 12) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
