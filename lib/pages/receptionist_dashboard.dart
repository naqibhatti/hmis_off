import 'package:flutter/material.dart';
import 'add_patient_page.dart';
import 'collect_vitals_page.dart';
import 'login_page.dart';
import '../widgets/common_header.dart';
import '../models/patient_data.dart';

class ReceptionistDashboard extends StatefulWidget {
  const ReceptionistDashboard({super.key});

  @override
  State<ReceptionistDashboard> createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard> {
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
            title: 'Receptionist Dashboard',
            userAccessLevel: 'Receptionist',
            showBackButton: false,
            onLogout: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
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
                      child: GridView.count(
                        crossAxisCount: 3,
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
    required bool isEnabled,
  }) {
    final ThemeData theme = Theme.of(context);
    
    return Card(
      elevation: isEnabled ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  )
                : null,
            color: isEnabled ? null : Colors.grey.shade100,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 48,
                  color: isEnabled ? color : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? theme.colorScheme.onSurface : Colors.grey.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
