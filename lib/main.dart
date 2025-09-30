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

    return MaterialApp(
      title: 'HMSOff',
      theme: ThemeData(
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
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => const LoginPage(),
        '/doctor-dashboard': (context) => const DoctorDashboard(),
        '/receptionist-dashboard': (context) => const ReceptionistDashboard(),
        '/add-patient': (context) => const AddPatientPage(),
        '/collect-vitals': (context) => const CollectVitalsPage(),
        '/diagnostic': (context) => const DiagnosticPage(),
        '/add-family': (context) => const AddFamilyPage(),
        // '/modify-family': (context) => ModifyFamilyPage(...), // requires args, not routed here
      },
    );
  }
}
