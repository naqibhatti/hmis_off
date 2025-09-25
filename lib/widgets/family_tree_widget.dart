import 'package:flutter/material.dart';
import '../models/family_data.dart';

class FamilyTreeWidget extends StatelessWidget {
  final Family family;

  const FamilyTreeWidget({
    super.key,
    required this.family,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Family Tree',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              _buildLegend(context),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: _buildFamilyTree(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTree(BuildContext context) {
    final theme = Theme.of(context);
    
    // Organize family members by relationship
    final headOfFamily = family.headOfFamily;
    final spouse = family.members.where((m) => m.relationship == 'Spouse').firstOrNull;
    final children = family.members.where((m) => 
      m.relationship == 'Son' || m.relationship == 'Daughter').toList();
    final parents = family.members.where((m) => 
      m.relationship == 'Father' || m.relationship == 'Mother').toList();
    final siblings = family.members.where((m) => 
      m.relationship == 'Brother' || m.relationship == 'Sister').toList();
    final others = family.members.where((m) => 
      !['Spouse', 'Son', 'Daughter', 'Father', 'Mother', 'Brother', 'Sister'].contains(m.relationship)).toList();

    return Column(
      children: [
        // Parents row (if any)
        if (parents.isNotEmpty) ...[
          _buildParentsRow(context, parents),
          const SizedBox(height: 20),
          _buildVerticalLine(),
          const SizedBox(height: 20),
        ],
        
        // Main family row (Head + Spouse)
        _buildMainFamilyRow(context, headOfFamily, spouse),
        
        // Children row (if any)
        if (children.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildVerticalLine(),
          const SizedBox(height: 20),
          _buildChildrenRow(context, children),
        ],
        
        // Siblings row (if any)
        if (siblings.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSiblingsRow(context, siblings),
        ],
        
        // Others row (if any)
        if (others.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildOthersRow(context, others),
        ],
      ],
    );
  }

  Widget _buildParentsRow(BuildContext context, List<FamilyMember> parents) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: parents.map((parent) => 
        _buildMemberCard(context, parent, isHead: false)
      ).toList(),
    );
  }

  Widget _buildMainFamilyRow(BuildContext context, FamilyMember head, FamilyMember? spouse) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMemberCard(context, head, isHead: true),
        if (spouse != null) ...[
          const SizedBox(width: 20),
          _buildMarriageLine(),
          const SizedBox(width: 20),
          _buildMemberCard(context, spouse, isHead: false),
        ],
      ],
    );
  }

  Widget _buildChildrenRow(BuildContext context, List<FamilyMember> children) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: children.map((child) => 
        _buildMemberCard(context, child, isHead: false)
      ).toList(),
    );
  }

  Widget _buildSiblingsRow(BuildContext context, List<FamilyMember> siblings) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: siblings.map((sibling) => 
        _buildMemberCard(context, sibling, isHead: false)
      ).toList(),
    );
  }

  Widget _buildOthersRow(BuildContext context, List<FamilyMember> others) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: others.map((other) => 
        _buildMemberCard(context, other, isHead: false)
      ).toList(),
    );
  }

  Widget _buildMemberCard(BuildContext context, FamilyMember member, {required bool isHead}) {
    final theme = Theme.of(context);
    
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHead ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHead ? theme.colorScheme.primary : theme.colorScheme.outline,
          width: isHead ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with gender indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isHead ? theme.colorScheme.primary : theme.colorScheme.secondary,
                child: Text(
                  member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isHead ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              // Gender indicator
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: member.gender == 'Male' ? Colors.blue : Colors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    member.gender == 'Male' ? Icons.male : Icons.female,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Name
          Text(
            member.fullName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHead ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Relationship badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isHead ? theme.colorScheme.primary : theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              member.relationship,
              style: TextStyle(
                fontSize: 10,
                color: isHead ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Age and Blood Group
          Text(
            '${member.age} years • ${member.bloodGroup}',
            style: TextStyle(
              fontSize: 9,
              color: isHead ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      width: 2,
      height: 20,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildMarriageLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.info_outline,
        color: theme.colorScheme.primary,
        size: 20,
      ),
      tooltip: 'Family Tree Legend',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'legend',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Family Tree Legend',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Text('Head of Family'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.male, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Text('Male'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.female, color: Colors.pink, size: 16),
                  SizedBox(width: 8),
                  Text('Female'),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Layout:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Parents at top'),
              Text('• Head & Spouse in center'),
              Text('• Children below'),
              Text('• Siblings on sides'),
            ],
          ),
        ),
      ],
    );
  }
}
