import 'package:flutter/material.dart';
import '../theme/shadcn_colors.dart';
import '../theme/theme_controller.dart';

class SquareTabWidget extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final List<bool>? tabEnabled;

  const SquareTabWidget({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.onTabChanged,
    this.tabEnabled,
  });

  @override
  State<SquareTabWidget> createState() => _SquareTabWidgetState();
}

class _SquareTabWidgetState extends State<SquareTabWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      if (widget.onTabChanged != null) {
        widget.onTabChanged!(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Square Tab Bar
        Container(
          height: 48, // Reduced height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeController.instance.useShadcn.value
                  ? Colors.grey.shade300
                  : Colors.green.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ThemeController.instance.useShadcn.value
                    ? ShadcnColors.accent.withOpacity(0.1)
                    : Colors.green.shade50,
                border: Border.all(
                  color: ThemeController.instance.useShadcn.value
                      ? ShadcnColors.accent.withOpacity(0.3)
                      : Colors.green.shade200,
                  width: 1,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: ThemeController.instance.useShadcn.value
                  ? ShadcnColors.accent700
                  : Colors.green.shade700,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                letterSpacing: 0.1,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              tabs: widget.tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isEnabled = widget.tabEnabled == null || widget.tabEnabled![index];
                
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isEnabled) ...[
                        Icon(
                          Icons.lock,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isEnabled 
                                ? (ThemeController.instance.useShadcn.value
                                    ? ShadcnColors.accent700
                                    : Colors.green.shade700)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
