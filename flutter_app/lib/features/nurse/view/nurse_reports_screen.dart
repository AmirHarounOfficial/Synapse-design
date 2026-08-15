import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `NurseReports.tsx`. A tab-root list of report sections; some are
/// navigable, the rest are disabled placeholders. English-only.
class NurseReportsScreen extends StatelessWidget {
  const NurseReportsScreen({super.key});

  static const List<({String id, String title, String description, int? badge, String? path})> _sections = [
    (id: 'generate', title: 'Generate Report', description: 'Create daily, weekly, or custom reports', badge: null, path: '/nurse/reports/generate'),
    (id: 'documents', title: 'Document Review', description: 'Review pending parent submissions', badge: 3, path: '/nurse/documents/review'),
    (id: 'medication', title: 'Medication Reports', description: 'Dose logs and compliance tracking', badge: null, path: null),
    (id: 'clinic', title: 'Clinic Visit Reports', description: 'Visit statistics and trends', badge: null, path: null),
    (id: 'compliance', title: 'Compliance Reports', description: 'Required screenings and documentation', badge: null, path: null),
  ];

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: const SchooKeepAppBar(title: 'Reports'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          children: [
            for (final s in _sections)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: s.path == null ? 0.5 : 1,
                  child: SchooKeepCard(
                    onTap: s.path == null ? null : () => context.go(s.path!),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.fileText, size: 24, color: SchooKeepColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(s.title,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                                  if (s.badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(color: SchooKeepColors.error, shape: BoxShape.circle),
                                      child: Text('${s.badge}',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(s.description,
                                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (s.path != null) ...[
                          const SizedBox(width: 8),
                          const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
