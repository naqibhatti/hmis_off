import 'package:flutter/material.dart';
import '../models/patient_data.dart';
import '../models/user_type.dart';
import '../services/patient_data_service.dart';
import '../theme/shadcn_colors.dart';

class PatientSelectionPage extends StatefulWidget {
  final UserType userType;

  const PatientSelectionPage({super.key, required this.userType});

  @override
  State<PatientSelectionPage> createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _visibleCount = 5;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
        _visibleCount = 5;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectPatient(PatientData patient) {
    PatientManager.setPatient(patient);
    final String route = widget.userType == UserType.doctor
        ? '/doctor-dashboard'
        : '/receptionist-dashboard';
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<PatientData> patients = PatientDataService.searchPatients(_query);
    final int itemCount = _visibleCount < patients.length ? _visibleCount : patients.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 650),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left pane: search field
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: ShadcnColors.accent700, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Search',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ShadcnColors.accent700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Name, CNIC, phone, gender, or age',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {},
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Type to filter the patients list on the right. Tap Add to continue.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              // Divider between panes
              Container(
                width: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.grey.shade300,
              ),
              // Right pane: patients list
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: ShadcnColors.accent700, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Available Patients',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ShadcnColors.accent700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${patients.length} found',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.builder(
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            final p = patients[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: ShadcnColors.accent100,
                                  child: Text(
                                    p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                                    style: TextStyle(color: ShadcnColors.accent700),
                                  ),
                                ),
                                title: Text(
                                  '${index + 1}. ${p.fullName}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${p.age}y • ${p.gender} • ${p.cnic}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: FilledButton(
                                  onPressed: () => _selectPatient(p),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: ShadcnColors.accent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Add'),
                                ),
                                onTap: () => _selectPatient(p),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (patients.length > itemCount) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 160,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _visibleCount += 5;
                              });
                            },
                            child: const Text('Load more'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


