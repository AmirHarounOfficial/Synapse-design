import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import 'schookeep_scaffold.dart';

/// Temporary screen for routes that are wired but not yet ported. Lets the full
/// route graph and navigation map work while screens are filled in role by role.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      title: title,
      onBack: onBack,
      scrollable: false,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.hammer, size: 40, color: SchooKeepColors.textSecondary),
            SizedBox(height: 12),
            Text('Screen not yet ported',
                style: TextStyle(color: SchooKeepColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
