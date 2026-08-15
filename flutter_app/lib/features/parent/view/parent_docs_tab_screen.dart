import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ParentDocsTab.tsx`. Documents tab listing each uploaded
/// document with a status chip (approved / pending / expiring) and either an
/// uploaded date or an expiry date.
class ParentDocsTabScreen extends StatelessWidget {
  const ParentDocsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    final documents = <({String name, String status, String? uploadedDate, String? expiryDate})>[
      (name: isRTL ? 'شهادة الميلاد' : 'Birth Certificate', status: 'approved', uploadedDate: isRTL ? '1 مايو 2026' : 'May 1, 2026', expiryDate: null),
      (name: isRTL ? 'بطاقة التأمين الصحي' : 'Health Insurance Card', status: 'expiring', uploadedDate: null, expiryDate: isRTL ? '22 يونيو 2026' : 'Jun 22, 2026'),
      (name: isRTL ? 'سجلات التطعيم' : 'Immunization Records', status: 'approved', uploadedDate: isRTL ? '1 مايو 2026' : 'May 1, 2026', expiryDate: null),
      (name: isRTL ? 'خطة رعاية الطبيب' : 'Physician Care Plan', status: 'pending', uploadedDate: isRTL ? '20 مايو 2026' : 'May 20, 2026', expiryDate: null),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: isRTL ? 'المستندات' : 'Documents'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < documents.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _documentCard(documents[i], isRTL),
            ],
          ],
        ),
      ),
    );
  }

  ({IconData icon, String textEn, String textAr, Color color, Color bg}) _statusConfig(String status) {
    switch (status) {
      case 'approved':
        return (icon: LucideIcons.checkCircle, textEn: 'Approved', textAr: 'معتمد', color: SchooKeepColors.accent, bg: SchooKeepColors.greenChipBg);
      case 'pending':
        return (icon: LucideIcons.clock, textEn: 'Pending Review', textAr: 'قيد المراجعة', color: SchooKeepColors.warning, bg: SchooKeepColors.amberChipBg);
      case 'expiring':
        return (icon: LucideIcons.alertTriangle, textEn: 'Expiring Soon', textAr: 'تنتهي قريباً', color: SchooKeepColors.error, bg: const Color(0xFFFEE2E2));
      default:
        return (icon: LucideIcons.fileText, textEn: 'Unknown', textAr: 'غير معروف', color: SchooKeepColors.textSecondary, bg: const Color(0xFFF3F4F6));
    }
  }

  Widget _documentCard(({String name, String status, String? uploadedDate, String? expiryDate}) doc, bool isRTL) {
    final cfg = _statusConfig(doc.status);
    return SchooKeepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Icon(LucideIcons.fileText, size: 24, color: cfg.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(cfg.icon, size: 14, color: cfg.color),
                    const SizedBox(width: 6),
                    Text(isRTL ? cfg.textAr : cfg.textEn, style: TextStyle(fontSize: 12, color: cfg.color)),
                  ],
                ),
                const SizedBox(height: 8),
                if (doc.uploadedDate != null)
                  Text(
                    isRTL ? 'تم الرفع ${doc.uploadedDate}' : 'Uploaded ${doc.uploadedDate}',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                if (doc.expiryDate != null)
                  Text(
                    isRTL ? 'تنتهي ${doc.expiryDate}' : 'Expires ${doc.expiryDate}',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.error),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
