import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  final String userAccessLevel;
  final VoidCallback? onLogout;
  final bool showBackButton;

  const CommonHeader({
    super.key,
    required this.title,
    required this.userAccessLevel,
    this.onLogout,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          // Back button
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
          ],
          // Logo
          SizedBox(
            height: 40,
            child: Image.asset(
              'assets/images/punjab.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.local_hospital,
                  size: 32,
                  color: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Title and user access level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Access Level: $userAccessLevel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Logout button
          if (onLogout != null)
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
            ),
        ],
      ),
    );
  }
}
