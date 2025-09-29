enum UserType {
  doctor,
  receptionist,
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.doctor:
        return 'Doctor';
      case UserType.receptionist:
        return 'Receptionist';
    }
  }

  String get icon {
    switch (this) {
      case UserType.doctor:
        return '👨‍⚕️';
      case UserType.receptionist:
        return '👩‍💼';
    }
  }
}
