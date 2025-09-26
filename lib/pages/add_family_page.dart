import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';
import '../models/patient_data.dart';
import '../models/family_data.dart';
import 'modify_family_page.dart';

class AddFamilyPage extends StatefulWidget {
  const AddFamilyPage({super.key});

  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  final TextEditingController _cnicController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Mock patient database - in real app this would come from backend
  final List<PatientData> _allPatients = [
    PatientData(
      fullName: 'John Doe',
      age: 35,
      bloodGroup: 'A+',
      email: 'john@example.com',
      phone: '0300-1234567',
      address: '123 Main Street, Lahore',
      cnic: '12345-1234567-1',
      gender: 'Male',
      dateOfBirth: DateTime(1989, 1, 1),
    ),
    PatientData(
      fullName: 'Jane Smith',
      age: 28,
      bloodGroup: 'B+',
      email: 'jane@example.com',
      phone: '0300-7654321',
      address: '456 Park Avenue, Karachi',
      cnic: '23456-2345678-2',
      gender: 'Female',
      dateOfBirth: DateTime(1996, 5, 15),
    ),
    PatientData(
      fullName: 'Ahmed Khan',
      age: 42,
      bloodGroup: 'O+',
      email: 'ahmed@example.com',
      phone: '0300-9876543',
      address: '789 Garden Road, Islamabad',
      cnic: '34567-3456789-3',
      gender: 'Male',
      dateOfBirth: DateTime(1982, 8, 20),
    ),
  ];

  List<PatientData> _searchResults = [];
  bool _isSearching = false;
  late VoidCallback _familyListener;
  Family? _newlyCreatedFamily;
  
  // For existing family search
  final TextEditingController _existingFamilyCnicController = TextEditingController();
  List<Family> _existingFamilyResults = [];
  bool _isSearchingExisting = false;

  @override
  void initState() {
    super.initState();
    _familyListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    FamilyManager.addListener(_familyListener);
  }

  @override
  void dispose() {
    _cnicController.dispose();
    _existingFamilyCnicController.dispose();
    FamilyManager.removeListener(_familyListener);
    super.dispose();
  }

  void _clearNewlyCreatedFamily() {
    setState(() {
      _newlyCreatedFamily = null;
    });
  }

  void _selectExistingFamily(Family family) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Family: ${family.familyName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Head: ${family.headOfFamily.fullName}'),
            Text('Members: ${family.allMembers.length}'),
            const SizedBox(height: 16),
            const Text('What would you like to do?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              _modifyExistingFamily(family);
            },
            child: const Text('Modify'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteExistingFamily(family);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _modifyExistingFamily(Family family) {
    final familyIndex = FamilyManager.families.indexWhere((f) => f.headOfFamily.cnic == family.headOfFamily.cnic);
    if (familyIndex != -1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ModifyFamilyPage(
            family: family,
            familyIndex: familyIndex,
          ),
        ),
      );
    }
  }

  void _deleteExistingFamily(Family family) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family'),
        content: Text('Are you sure you want to delete ${family.familyName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final familyIndex = FamilyManager.families.indexWhere((f) => f.headOfFamily.cnic == family.headOfFamily.cnic);
              if (familyIndex != -1) {
                FamilyManager.deleteFamily(familyIndex);
                setState(() {
                  _existingFamilyResults.clear();
                  _existingFamilyCnicController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${family.familyName} deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _cnicValidator(String? value) {
    final String? requiredResult = _requiredValidator(value, fieldName: 'CNIC');
    if (requiredResult != null) return requiredResult;
    
    final RegExp pattern = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Enter CNIC as 12345-1234567-1';
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
        out.write('-');
      }
    }
    return out.toString();
  }

  void _searchPatients() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSearching = true;
      });

      // Simulate search delay
      Future.delayed(const Duration(milliseconds: 500), () {
        final searchCnic = _cnicController.text.trim();
        _searchResults = _allPatients.where((patient) {
          return patient.cnic.toLowerCase().contains(searchCnic.toLowerCase());
        }).toList();

        setState(() {
          _isSearching = false;
        });

        if (_searchResults.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No patients found with this CNIC'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  void _searchExistingFamilies() {
    final searchCnic = _existingFamilyCnicController.text.trim();
    if (searchCnic.isEmpty) {
      setState(() {
        _existingFamilyResults.clear();
      });
      return;
    }

    setState(() {
      _isSearchingExisting = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _existingFamilyResults = FamilyManager.families.where((family) {
        return family.headOfFamily.cnic.toLowerCase().contains(searchCnic.toLowerCase());
      }).toList();

      setState(() {
        _isSearchingExisting = false;
      });

      if (_existingFamilyResults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No existing families found with this CNIC'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _selectPatient(PatientData patient) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Head of Family: ${patient.fullName}'),
            Text('Age: ${patient.age} years'),
            Text('CNIC: ${patient.cnic}'),
            Text('Blood Group: ${patient.bloodGroup}'),
            const SizedBox(height: 8),
            Text('Family Name: ${patient.fullName.split(' ').last} Family'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createFamily(patient);
            },
            child: const Text('Create Family'),
          ),
        ],
      ),
    );
  }

  void _createFamily(PatientData patient) {
    final headOfFamily = FamilyMember.fromPatientData(patient, 'Head of Family');
    final newFamily = Family(
      headOfFamily: headOfFamily,
      members: [],
    );
    
    FamilyManager.addFamily(newFamily);
    
    // Set the newly created family to show only this one
    setState(() {
      _newlyCreatedFamily = newFamily;
      _searchResults.clear();
      _cnicController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newFamily.familyName} created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _modifyFamily(int familyIndex) {
    final family = FamilyManager.families[familyIndex];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModifyFamilyPage(
          family: family,
          familyIndex: familyIndex,
        ),
      ),
    );
  }

  void _deleteFamily(int familyIndex) {
    final family = FamilyManager.families[familyIndex];
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family'),
        content: Text('Are you sure you want to delete ${family.familyName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              FamilyManager.deleteFamily(familyIndex);
              
              // Clear the newly created family if it was deleted
              if (_newlyCreatedFamily != null && 
                  _newlyCreatedFamily!.headOfFamily.cnic == family.headOfFamily.cnic) {
                setState(() {
                  _newlyCreatedFamily = null;
                });
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${family.familyName} deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          CommonHeader(
            title: 'Add Family',
            userAccessLevel: 'Doctor',
            showBackButton: true,
            onLogout: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Family',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                TextFormField(
                  controller: _cnicController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'Enter Head of Family\'s CNIC',
                    hintText: '12345-1234567-1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    _CnicInputFormatter(),
                  ],
                  validator: _cnicValidator,
                  onFieldSubmitted: (_) => _searchPatients(),
                ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _isSearching ? null : _searchPatients,
                              icon: _isSearching 
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.search),
                              label: Text(_isSearching ? 'Searching...' : 'Search Patients'),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Existing Family Search Section
                          Text(
                            'Search Existing Family',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _existingFamilyCnicController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              labelText: 'Enter Head of Family\'s CNIC',
                              hintText: '12345-1234567-1',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.family_restroom),
                            ),
                            inputFormatters: <TextInputFormatter>[
                              _CnicInputFormatter(),
                            ],
                            onFieldSubmitted: (_) => _searchExistingFamilies(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _isSearchingExisting ? null : _searchExistingFamilies,
                              icon: _isSearchingExisting 
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.search),
                              label: Text(_isSearchingExisting ? 'Searching...' : 'Search Existing Families'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Search results
                  if (_searchResults.isNotEmpty) ...[
                    Text(
                      'Search Results',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final patient = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  patient.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                patient.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Age: ${patient.age} years'),
                                  Text('CNIC: ${patient.cnic}'),
                                  Text('Blood Group: ${patient.bloodGroup}'),
                                ],
                              ),
                              trailing: FilledButton(
                                onPressed: () => _selectPatient(patient),
                                child: const Text('Create Family'),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // Show search results or newly created family
                    if (_searchResults.isNotEmpty) ...[
                      Text(
                        'Search Results',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final patient = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    patient.fullName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(patient.fullName),
                                subtitle: Text('CNIC: ${patient.cnic} • Age: ${patient.age}'),
                                trailing: FilledButton(
                                  onPressed: () => _selectPatient(patient),
                                  child: const Text('Create Family'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else if (_existingFamilyResults.isNotEmpty) ...[
                      Text(
                        'Existing Families Found',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _existingFamilyResults.length,
                          itemBuilder: (context, index) {
                            final family = _existingFamilyResults[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondary,
                                  child: const Icon(
                                    Icons.family_restroom,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(family.familyName),
                                subtitle: Text('Head: ${family.headOfFamily.fullName} • Members: ${family.allMembers.length}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FilledButton.tonal(
                                      onPressed: () => _selectExistingFamily(family),
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(80, 36),
                                      ),
                                      child: const Text('Select'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else if (_newlyCreatedFamily != null) ...[
                      Row(
                        children: [
                          Text(
                            'Created Family',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.tonal(
                            onPressed: _clearNewlyCreatedFamily,
                            child: const Text('Create New Family'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: theme.colorScheme.primary,
                                      child: Text(
                                        _newlyCreatedFamily!.headOfFamily.fullName[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _newlyCreatedFamily!.familyName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Head: ${_newlyCreatedFamily!.headOfFamily.fullName}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            'Members: ${_newlyCreatedFamily!.allMembers.length}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        FilledButton.tonal(
                                          onPressed: () {
                                            // Find the index of the newly created family
                                            final familyIndex = FamilyManager.families.indexWhere(
                                              (f) => f.headOfFamily.cnic == _newlyCreatedFamily!.headOfFamily.cnic
                                            );
                                            if (familyIndex != -1) {
                                              _modifyFamily(familyIndex);
                                            }
                                          },
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size(80, 36),
                                          ),
                                          child: const Text('Modify'),
                                        ),
                                        const SizedBox(height: 8),
                                        FilledButton(
                                          onPressed: () {
                                            // Find the index of the newly created family
                                            final familyIndex = FamilyManager.families.indexWhere(
                                              (f) => f.headOfFamily.cnic == _newlyCreatedFamily!.headOfFamily.cnic
                                            );
                                            if (familyIndex != -1) {
                                              _deleteFamily(familyIndex);
                                            }
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: theme.colorScheme.error,
                                            foregroundColor: theme.colorScheme.onError,
                                            minimumSize: const Size(80, 36),
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Empty state when no family is created
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.family_restroom,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No family created yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Search for a patient to create your first family',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
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
    final String formatted = _AddFamilyPageState._formatCnic(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

