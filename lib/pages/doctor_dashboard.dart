import 'package:flutter/material.dart';
import 'add_patient_page.dart';
import 'collect_vitals_page.dart';
import 'add_family_page.dart';
import 'diagnostic_page.dart';
import 'login_page.dart';
import '../models/patient_data.dart';
import '../services/patient_data_service.dart';
import '../theme/shadcn_colors.dart';
import '../widgets/side_navigation_drawer.dart';
import '../theme/theme_controller.dart';
import 'patient_selection_page.dart';
import '../models/user_type.dart';

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
      backgroundColor: ThemeController.instance.useShadcn.value
          ? Colors.grey.shade50
          : Colors.green.shade50,
      body: SideNavigationDrawer(
        currentRoute: '/doctor-dashboard',
        userType: 'Doctor',
        child: Column(
          children: <Widget>[
            // HMIS section (moved to top, compact height)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeController.instance.useShadcn.value
                      ? Colors.white
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with title and theme toggle
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent200
                                : Colors.green.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            color: ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade800,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'HMIS (PRIMARY HEALTH FACILITIES)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ThemeController.instance.useShadcn.value
                                  ? ShadcnColors.accent700
                                  : Colors.green.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Toggle theme (Shadcn / Green)',
                          onPressed: () {
                            ThemeController.instance.toggle();
                            setState(() {});
                          },
                          icon: ValueListenableBuilder<bool>(
                            valueListenable: ThemeController.instance.useShadcn,
                            builder: (context, useShadcn, _) {
                              return Icon(
                                useShadcn ? Icons.palette : Icons.grass,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Selected patient card
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: ShadcnColors.accent700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Selected Patient',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnColors.accent700,
                                ),
                              ),
                              const Spacer(),
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
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (_) {
                              final p = PatientManager.currentPatient;
                              if (p == null) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text('No patient selected. Tap the change icon to select a patient.'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: ShadcnColors.accent100,
                                    child: Text(p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                                        style: TextStyle(color: ShadcnColors.accent700)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${p.fullName} • ${p.age}y • ${p.gender} • ${p.cnic}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Compact details row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Name',
                            'Dr. Muhammad Ali',
                            ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade800,
                            Colors.grey.shade600,
                            Icons.person,
                            isBold: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            'Designation',
                            'Doctor',
                            ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade800,
                            Colors.grey.shade600,
                            Icons.medical_services,
                            isBold: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            'Facility Name',
                            'Basic Health Unit HISDU, Lahore City, Lahore',
                            ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade800,
                            Colors.grey.shade600,
                            Icons.location_on,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            'User ID',
                            'MDU-01',
                            ThemeController.instance.useShadcn.value
                                ? ShadcnColors.accent700
                                : Colors.green.shade800,
                            Colors.grey.shade600,
                            Icons.badge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cards grid
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // duplicate HMIS section removed
                      // Cards grid
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeController.instance.useShadcn.value
                                  ? Colors.grey.shade300
                                  : Colors.green.shade200,
                              width: 1.8,
                            ),
                          ),
                          child: GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: _buildDashboardCards(context),
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
      ),
    );
  }

  List<Widget> _buildDashboardCards(BuildContext context) {
    final List<Widget> cards = [];

    cards.add(
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
    );

    cards.add(
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CollectVitalsPage(),
              ),
            );
          }
        },
        isEnabled: true,
      ),
    );

    cards.add(
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
    );

    final patient = PatientManager.currentPatient;
    final bool isFemaleOver14 = patient != null && patient.gender == 'Female' && patient.age > 14;
    final bool isUnder14 = patient != null && patient.age < 14;
    final bool isAdultMale = patient != null && patient.gender == 'Male' && patient.age >= 18;

    if (isFemaleOver14) {
      cards.add(
        _buildDashboardCard(
          context: context,
          title: 'Pregnancy',
          icon: Icons.pregnant_woman,
          color: Colors.pink,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pregnancy feature coming soon')),
            );
          },
          isEnabled: true,
        ),
      );

      // Family Planning for adult females
      cards.add(
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
      );
    }

    // Family Planning for adult males
    if (isAdultMale) {
      cards.add(
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
      );
    }

    if (isUnder14) {
      cards.add(
        _buildDashboardCard(
          context: context,
          title: 'Immunization',
          icon: Icons.vaccines,
          color: Colors.teal,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Immunization feature coming soon')),
            );
          },
          isEnabled: true,
        ),
      );
    }

    return cards;
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
      case 'Family Planning':
        return 'خاندانی منصوبہ بندی';
      case 'Pregnancy':
        return 'حمل';
      case 'Immunization':
        return 'ٹیکہ لگانا';
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
