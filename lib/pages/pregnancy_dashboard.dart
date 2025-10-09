import 'package:flutter/material.dart';
import '../models/patient_data.dart';
import '../services/patient_data_service.dart';
import '../theme/shadcn_colors.dart';
import '../widgets/side_navigation_drawer.dart';
import '../theme/theme_controller.dart';
import 'patient_selection_page.dart';
import '../models/user_type.dart';

class PregnancyDashboard extends StatefulWidget {
  const PregnancyDashboard({super.key});

  @override
  State<PregnancyDashboard> createState() => _PregnancyDashboardState();
}

class _PregnancyDashboardState extends State<PregnancyDashboard> {
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
        currentRoute: '/pregnancy-dashboard',
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
                    // Selected patient (compact)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
                              CircleAvatar(
                                radius: 18,
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
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: _buildPregnancyCards(context),
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

  List<Widget> _buildPregnancyCards(BuildContext context) {
    final List<Widget> cards = [];

    // Antenatal Care (ANC)
    cards.add(
      _buildPregnancyCard(
        context: context,
        title: 'Antenatal Care',
        subtitle: 'ANC',
        icon: Icons.pregnant_woman,
        color: Colors.pink,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Antenatal Care feature coming soon'),
              backgroundColor: Colors.pink,
            ),
          );
        },
        isEnabled: true,
      ),
    );

    // Delivery and Newborn Care
    cards.add(
      _buildPregnancyCard(
        context: context,
        title: 'Delivery & Newborn Care',
        subtitle: 'Delivery',
        icon: Icons.child_care,
        color: Colors.blue,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delivery & Newborn Care feature coming soon'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        isEnabled: true,
      ),
    );

    // Postnatal Care (PNC)
    cards.add(
      _buildPregnancyCard(
        context: context,
        title: 'Postnatal Care',
        subtitle: 'PNC',
        icon: Icons.family_restroom,
        color: Colors.green,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Postnatal Care feature coming soon'),
              backgroundColor: Colors.green,
            ),
          );
        },
        isEnabled: true,
      ),
    );

    return cards;
  }

  Widget _buildPregnancyCard({
    required BuildContext context,
    required String title,
    required String subtitle,
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
                  size: 48,
                  color: isEnabled ? color : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? theme.colorScheme.onSurface : Colors.grey.shade500,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? color : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
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
      case 'Antenatal Care':
        return 'حمل سے پہلے کی دیکھ بھال';
      case 'Delivery & Newborn Care':
        return 'زچگی اور نوزائیدہ کی دیکھ بھال';
      case 'Postnatal Care':
        return 'زچگی کے بعد کی دیکھ بھال';
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
