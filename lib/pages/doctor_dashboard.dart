import 'package:flutter/material.dart';
import 'add_patient_page.dart';
import 'collect_vitals_page.dart';
import 'add_family_page.dart';
import '../widgets/common_header.dart';
import '../models/patient_data.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  late VoidCallback _patientListener;

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
    PatientManager.removeListener(_patientListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: <Widget>[
          // Header section
          CommonHeader(
            title: 'Doctor Dashboard',
            userAccessLevel: 'Doctor',
            showBackButton: false,
            onLogout: () {
              Navigator.of(context).pop();
            },
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
              // Cards grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(60),
                  child:                   GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: <Widget>[
                    _buildDashboardCard(
                      context: context,
                      title: 'Add Patient',
                      icon: Icons.person_add,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddPatientPage(),
                          ),
                        );
                      },
                      isEnabled: true, // Always enabled
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Add Family',
                      icon: Icons.family_restroom,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddFamilyPage(),
                          ),
                        );
                      },
                      isEnabled: true,
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Collect Vitals',
                      icon: Icons.favorite,
                      color: Colors.red,
                      onTap: () {
                        if (PatientManager.hasPatient) {
                          final patient = PatientManager.currentPatient!;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CollectVitalsPage(
                                patientName: patient.fullName,
                                patientAge: patient.age,
                                patientBloodGroup: patient.bloodGroup,
                              ),
                            ),
                          );
                        } else {
                          // Navigate to Collect Vitals without patient data
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CollectVitalsPage(),
                            ),
                          );
                        }
                      },
                      isEnabled: true,
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Diagnosis & Prescription',
                      icon: Icons.medical_services,
                      color: Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Diagnosis & Prescription feature coming soon')),
                        );
                      },
                      isEnabled: true,
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'LHV',
                      icon: Icons.pregnant_woman,
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('LHV feature coming soon')),
                        );
                      },
                      isEnabled: true,
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Family Planning',
                      icon: Icons.family_restroom,
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Family Planning feature coming soon')),
                        );
                      },
                      isEnabled: true,
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Integrated Screening',
                      icon: Icons.search,
                      color: Colors.teal,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Integrated Screening feature coming soon')),
                        );
                      },
                      isEnabled: true,
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

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: isEnabled ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isEnabled ? 0.1 : 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color.withOpacity(isEnabled ? 1.0 : 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(isEnabled ? 1.0 : 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isEnabled) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Add patient first',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
