import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/login_page.dart';
import 'theme/shadcn_colors.dart';
import 'pages/doctor_dashboard.dart';
import 'pages/receptionist_dashboard.dart';
import 'pages/add_patient_page.dart';
import 'pages/collect_vitals_page.dart';
import 'pages/diagnostic_page.dart';
import 'pages/add_family_page.dart';
import 'pages/modify_family_page.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force landscape as default orientation for a tablet-first layout.
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.useShadcn,
      builder: (context, useShadcn, _) {
        final ThemeData shadcnLight = ThemeData(
          colorScheme: const ColorScheme.light(
            primary: ShadcnColors.primary,
            onPrimary: ShadcnColors.primaryForeground,
            secondary: ShadcnColors.secondary,
            onSecondary: ShadcnColors.secondaryForeground,
            surface: ShadcnColors.background,
            onSurface: ShadcnColors.foreground,
            background: ShadcnColors.background,
            onBackground: ShadcnColors.foreground,
            error: ShadcnColors.destructive,
            onError: ShadcnColors.destructiveForeground,
          ),
          useMaterial3: true,
        );

        final ThemeData greenLight = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        );

        return MaterialApp(
          title: 'HMSOff',
          theme: useShadcn ? shadcnLight : greenLight,
          home: const LoginPage(),
          routes: <String, WidgetBuilder>{
            '/doctor-dashboard': (context) => const DoctorDashboard(),
            '/receptionist-dashboard': (context) => const ReceptionistDashboard(),
            '/add-patient': (context) => const AddPatientPage(),
            '/collect-vitals': (context) => const CollectVitalsPage(),
            '/diagnostic': (context) => const DiagnosticPage(),
            '/add-family': (context) => const AddFamilyPage(),
          },
        );
      },
    );
  }
}
