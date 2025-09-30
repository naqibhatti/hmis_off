import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  // true = use Shadcn theme, false = use Green theme
  final ValueNotifier<bool> useShadcn = ValueNotifier<bool>(true);

  void toggle() {
    useShadcn.value = !useShadcn.value;
  }

  void set(bool value) {
    useShadcn.value = value;
  }
}
