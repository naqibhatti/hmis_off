import 'package:flutter/material.dart';
import 'add_patient_page.dart';
import 'collect_vitals_page.dart';
import 'add_family_page.dart';
import 'diagnostic_page.dart';
import 'login_page.dart';
import '../models/patient_data.dart';
import '../theme/shadcn_colors.dart';

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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    // User Information Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ShadcnColors.accent300, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: ShadcnColors.accent100,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  ShadcnColors.accent50,
                                  ShadcnColors.accent100,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ShadcnColors.accent200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.local_hospital,
                                    color: ShadcnColors.accent700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'HMIS (PRIMARY HEALTH FACILITIES)',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: ShadcnColors.accent700,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          // User Details
                          Row(
                            children: [
                              // Left Column - Name & Connection Status
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildInfoCard(
                                      'Name',
                                      'Dr. Muhammad Ali',
                                      ShadcnColors.accent700,
                                      Colors.red.shade600,
                                      Icons.person,
                                      isBold: true,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildInfoCard(
                                      'Connection Status',
                                      'Connected',
                                      ShadcnColors.accent700,
                                      Colors.grey.shade600,
                                      Icons.wifi,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Middle Column - Designation & User ID
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildInfoCard(
                                      'Designation',
                                      'Doctor',
                                      ShadcnColors.accent700,
                                      Colors.red.shade600,
                                      Icons.medical_services,
                                      isBold: true,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildInfoCard(
                                      'User ID',
                                      'MDU-01',
                                      ShadcnColors.accent700,
                                      Colors.grey.shade600,
                                      Icons.badge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right Column - Facility & Timestamp
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildInfoCard(
                                      'Facility Name',
                                      'Basic Health Unit HISDU, Lahore City, Lahore',
                                      ShadcnColors.accent700,
                                      Colors.grey.shade600,
                                      Icons.location_on,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoCard(
                                      'Last Login',
                                      '02-07-2024 06:40:20',
                                      ShadcnColors.accent700,
                                      Colors.grey.shade600,
                                      Icons.access_time,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Cards grid
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ShadcnColors.accent50,
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
                      color: ShadcnColors.accent,
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

  Widget _buildInfoCard(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
    IconData icon, {
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: labelColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: labelColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: labelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: labelColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    fontSize: isBold ? 16 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
