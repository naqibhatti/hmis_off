import 'package:flutter/material.dart';
import '../theme/shadcn_colors.dart';

class SideNavigationDrawer extends StatefulWidget {
  final String currentRoute;
  final String userType;
  final Widget child;

  const SideNavigationDrawer({
    super.key,
    required this.currentRoute,
    required this.userType,
    required this.child,
  });

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  bool _isExpanded = false; // Always minimized by default

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Side Navigation Drawer
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isExpanded ? 180 : 80,
          height: double.infinity,
          decoration: BoxDecoration(
            color: ShadcnColors.background,
            border: Border(
              right: BorderSide(
                color: ShadcnColors.border,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: ShadcnColors.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _isExpanded ? 14 : 6,
                  vertical: _isExpanded ? 10 : 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ShadcnColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      icon: Icon(
                        _isExpanded ? Icons.chevron_left : Icons.menu,
                        color: ShadcnColors.mutedForeground,
                        size: _isExpanded ? 16 : 16,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: ShadcnColors.muted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        minimumSize: const Size(24, 24),
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ],
                ),
              ),
              
              // User Info
              if (_isExpanded)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: ShadcnColors.accent100,
                        child: Icon(
                          widget.userType == 'Doctor' 
                              ? Icons.person_outline 
                              : Icons.support_agent,
                          color: ShadcnColors.accent700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userType,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ShadcnColors.foreground,
                              ),
                            ),
                            Text(
                              'Logged In',
                              style: TextStyle(
                                fontSize: 12,
                                color: ShadcnColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      route: widget.userType == 'Doctor' 
                          ? '/doctor-dashboard' 
                          : '/receptionist-dashboard',
                      isActive: widget.currentRoute == '/doctor-dashboard' || 
                               widget.currentRoute == '/receptionist-dashboard',
                    ),
                     if (widget.userType == 'Doctor') ...[
                       _buildNavItem(
                         icon: Icons.favorite_outlined,
                         label: 'Collect Vitals',
                         route: '/collect-vitals',
                         isActive: widget.currentRoute == '/collect-vitals',
                       ),
                       _buildNavItem(
                         icon: Icons.medical_services_outlined,
                         label: 'Diagnosis',
                         route: '/diagnostic',
                         isActive: widget.currentRoute == '/diagnostic',
                       ),
                     ],
                     if (widget.userType == 'Receptionist') ...[
                       _buildNavItem(
                         icon: Icons.favorite_outlined,
                         label: 'Collect Vitals',
                         route: '/collect-vitals',
                         isActive: widget.currentRoute == '/collect-vitals',
                       ),
                     ],
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: EdgeInsets.all(_isExpanded ? 12 : 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: ShadcnColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildNavItem(
                  icon: Icons.logout_outlined,
                  label: 'Logout',
                  route: '/logout',
                  isActive: false,
                  isLogout: true,
                ),
              ),
            ],
          ),
        ),
        
        // Main Content
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isLogout) {
              _showLogoutDialog();
            } else {
              _navigateToRoute(route);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isExpanded ? 12 : 8,
              vertical: _isExpanded ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: isActive 
                  ? ShadcnColors.accent50 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive 
                  ? Border.all(
                      color: ShadcnColors.accent200,
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: _isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: _isExpanded ? 18 : 18,
                  color: isActive 
                      ? ShadcnColors.accent700 
                      : (isLogout ? ShadcnColors.destructive : ShadcnColors.mutedForeground),
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive 
                            ? ShadcnColors.accent700 
                            : (isLogout ? ShadcnColors.destructive : ShadcnColors.foreground),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(String route) {
    if (route == widget.currentRoute) {
      return;
    }
    if (route == '/logout') {
      _showLogoutDialog();
      return;
    }
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Fallback: navigate to dashboard depending on userType
      final String fallback = widget.userType == 'Doctor'
          ? '/doctor-dashboard'
          : '/receptionist-dashboard';
      if (widget.currentRoute != fallback) {
        Navigator.of(context).pushReplacementNamed(fallback);
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login page
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
