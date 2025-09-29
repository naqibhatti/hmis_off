import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_header.dart';
import '../widgets/family_tree_widget.dart';
import '../models/patient_data.dart';
import '../models/family_data.dart';

class ModifyFamilyPage extends StatefulWidget {
  final Family family;
  final int familyIndex;

  const ModifyFamilyPage({
    super.key,
    required this.family,
    required this.familyIndex,
  });

  @override
  State<ModifyFamilyPage> createState() => _ModifyFamilyPageState();
}

class _ModifyFamilyPageState extends State<ModifyFamilyPage> {
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
    PatientData(
      fullName: 'Sarah Khan',
      age: 25,
      bloodGroup: 'A-',
      email: 'sarah@example.com',
      phone: '0300-1111111',
      address: '789 Garden Road, Islamabad',
      cnic: '34567-3456789-4',
      gender: 'Female',
      dateOfBirth: DateTime(1999, 3, 10),
    ),
    PatientData(
      fullName: 'Ali Khan',
      age: 8,
      bloodGroup: 'O+',
      email: 'ali@example.com',
      phone: '0300-2222222',
      address: '789 Garden Road, Islamabad',
      cnic: '34567-3456789-5',
      gender: 'Male',
      dateOfBirth: DateTime(2016, 7, 15),
    ),
    PatientData(
      fullName: 'Fatima Khan',
      age: 5,
      bloodGroup: 'A+',
      email: 'fatima@example.com',
      phone: '0300-3333333',
      address: '789 Garden Road, Islamabad',
      cnic: '34567-3456789-6',
      gender: 'Female',
      dateOfBirth: DateTime(2019, 2, 20),
    ),
    PatientData(
      fullName: 'Hassan Khan',
      age: 65,
      bloodGroup: 'B+',
      email: 'hassan@example.com',
      phone: '0300-4444444',
      address: '789 Garden Road, Islamabad',
      cnic: '34567-3456789-7',
      gender: 'Male',
      dateOfBirth: DateTime(1959, 8, 10),
    ),
    PatientData(
      fullName: 'Aisha Khan',
      age: 60,
      bloodGroup: 'A-',
      email: 'aisha@example.com',
      phone: '0300-5555555',
      address: '789 Garden Road, Islamabad',
      cnic: '34567-3456789-8',
      gender: 'Female',
      dateOfBirth: DateTime(1964, 12, 5),
    ),
  ];

  List<PatientData> _searchResults = [];
  bool _isSearching = false;
  late VoidCallback _familyListener;
  Family? _currentFamily;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFamily = widget.family;
    _familyListener = () {
      if (mounted) {
        // Update the current family from FamilyManager
        final updatedFamily = FamilyManager.families.length > widget.familyIndex 
            ? FamilyManager.families[widget.familyIndex] 
            : null;
        if (updatedFamily != null) {
          setState(() {
            _currentFamily = updatedFamily;
          });
        }
      }
    };
    FamilyManager.addListener(_familyListener);
  }

  @override
  void dispose() {
    _cnicController.dispose();
    FamilyManager.removeListener(_familyListener);
    super.dispose();
  }

  void _searchPatientsByCNIC() {
    if (_currentFamily == null) return;
    
    final searchCnic = _cnicController.text.trim();
    if (searchCnic.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _searchResults = _allPatients.where((patient) {
        // Exclude existing family members
        final existingCNICs = _currentFamily!.allMembers.map((member) => member.cnic).toList();
        return patient.cnic.toLowerCase().contains(searchCnic.toLowerCase()) &&
               !existingCNICs.contains(patient.cnic);
      }).toList();

      setState(() {
        _isSearching = false;
      });
    });
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

  void _addFamilyMember(PatientData patient) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Family Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${patient.fullName}'),
            Text('Age: ${patient.age} years'),
            Text('CNIC: ${patient.cnic}'),
            Text('Blood Group: ${patient.bloodGroup}'),
            const SizedBox(height: 16),
            const Text('Relationship to Head of Family:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Relationship',
              ),
              items: const [
                DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                DropdownMenuItem(value: 'Son', child: Text('Son')),
                DropdownMenuItem(value: 'Daughter', child: Text('Daughter')),
                DropdownMenuItem(value: 'Father', child: Text('Father')),
                DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                DropdownMenuItem(value: 'Brother', child: Text('Brother')),
                DropdownMenuItem(value: 'Sister', child: Text('Sister')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _addMemberWithRelationship(patient, value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addMemberWithRelationship(PatientData patient, String relationship) {
    if (_currentFamily == null) return;
    
    final newMember = FamilyMember.fromPatientData(patient, relationship);
    final updatedFamily = _currentFamily!.addMember(newMember);
    
    FamilyManager.updateFamily(widget.familyIndex, updatedFamily);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${patient.fullName} added as $relationship'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear search results
    setState(() {
      _searchResults.clear();
      _cnicController.clear();
    });
  }

  void _removeFamilyMember(FamilyMember member) {
    if (_currentFamily == null) return;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Family Member'),
        content: Text('Are you sure you want to remove ${member.fullName} from ${_currentFamily!.familyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final updatedFamily = _currentFamily!.removeMember(member);
              FamilyManager.updateFamily(widget.familyIndex, updatedFamily);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member.fullName} removed from family'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
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
            title: 'Modify ${_currentFamily?.familyName ?? widget.family.familyName}',
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
                  // Family info section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentFamily?.familyName ?? widget.family.familyName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Head of Family: ${_currentFamily?.headOfFamily.fullName ?? widget.family.headOfFamily.fullName}',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'Total Members: ${_currentFamily?.allMembers.length ?? widget.family.allMembers.length}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tab view for Family Tree and Member Management
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            onTap: (index) {
                              setState(() {
                                _selectedTabIndex = index;
                              });
                            },
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.account_tree),
                                text: 'Family Tree',
                              ),
                              Tab(
                                icon: Icon(Icons.people),
                                text: 'Manage Members',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Family Tree Tab
                                FamilyTreeWidget(
                                  family: _currentFamily ?? widget.family,
                                ),
                                // Member Management Tab
                                _buildMemberManagementTab(context),
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
        ],
      ),
    );
  }

  Widget _buildMemberManagementTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Add new member section
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
                  'Add New Family Member',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cnicController,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String formatted = _formatCnic(newValue.text);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                  validator: _cnicValidator,
                  decoration: const InputDecoration(
                    labelText: 'Enter Family Member\'s CNIC',
                    hintText: '12345-1234567-1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  onChanged: (value) {
                    _searchPatientsByCNIC();
                  },
                  onFieldSubmitted: (value) {
                    _searchPatientsByCNIC();
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isSearching ? null : _searchPatientsByCNIC,
                    icon: _isSearching 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? 'Searching...' : 'Search by CNIC'),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Search results or family members list
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
                    trailing: FilledButton.tonal(
                      onPressed: () => _addFamilyMember(patient),
                      child: const Text('Add'),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ] else ...[
          // Family members list
          Text(
            'Family Members',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _currentFamily?.allMembers.length ?? widget.family.allMembers.length,
              itemBuilder: (context, index) {
                final family = _currentFamily ?? widget.family;
                final member = family.allMembers[index];
                final isHeadOfFamily = member.cnic == family.headOfFamily.cnic;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isHeadOfFamily 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.secondary,
                      child: Text(
                        member.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          member.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (isHeadOfFamily) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'HEAD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${member.relationship} • Age: ${member.age} years'),
                        Text('CNIC: ${member.cnic} • Blood Group: ${member.bloodGroup}'),
                      ],
                    ),
                    trailing: isHeadOfFamily
                        ? null
                        : IconButton.filledTonal(
                            onPressed: () => _removeFamilyMember(member),
                            icon: const Icon(Icons.remove_circle_outline),
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                          ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

