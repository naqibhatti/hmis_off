import 'package:flutter/material.dart';
import 'add_patient_page.dart';
import 'collect_vitals_page.dart';
import 'add_family_page.dart';
import 'diagnostic_page.dart';
import 'login_page.dart';
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
          // Main content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade50,
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    // Welcome message
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade50,
                            Colors.purple.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medical_services,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, Doctor!',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage patients and their health records efficiently',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Cards grid
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: GridView.count(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                    children: <Widget>[
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DiagnosticPage(),
                          ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withOpacity(0.2),
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 42,
                  color: isEnabled ? color : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? theme.colorScheme.onSurface : Colors.grey.shade500,
                    fontSize: 21,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getUrduTranslation(title),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? theme.colorScheme.onSurface.withOpacity(0.7) : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isEnabled) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Add patient first',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
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

  String _getUrduTranslation(String title) {
    switch (title) {
      case 'Add Family':
        return 'خاندانی تفصیلات ان پٹ کریں';
      case 'Collect Vitals':
        return 'حیاتیاتی علامات جمع کریں';
      case 'Diagnosis & Prescription':
        return 'تشخیص اور نسخہ';
      case 'LHV':
        return 'لیڈی ہیلتھ ورکر';
      case 'Family Planning':
        return 'خاندانی منصوبہ بندی';
      case 'Integrated Screening':
        return 'مربوط اسکریننگ';
      default:
        return title;
    }
  }
}
