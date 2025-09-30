import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/login_page.dart';
import 'theme/shadcn_colors.dart';

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
      home: const LoginPage(),
    );
  }
}
