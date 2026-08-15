import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';

/// Local copy ported from `PhysicianApprovalCard.tsx`. Shows either an
/// "approved" (green) or "pending" (amber) state. In the pending state the
/// "Notify On-Duty Physician" button is one-shot (`notified` local state).
class PhysicianApprovalCard extends StatefulWidget {
  const PhysicianApprovalCard({
    super.key,
    required this.status,
    this.approvedBy = 'Dr. Amina Al-Hashimi',
    this.licenseNumber = 'DHA MD-4029',
    this.approvedAt = '15/06/2026 at 09:45:12',
    this.onNotify,
  });

  /// 'approved' or 'pending'.
  final String status;
  final String approvedBy;
  final String licenseNumber;
  final String approvedAt;
  final VoidCallback? onNotify;

  @override
  State<PhysicianApprovalCard> createState() => _PhysicianApprovalCardState();
}

class _PhysicianApprovalCardState extends State<PhysicianApprovalCard> {
  bool _notified = false;

  void _handleNotify() {
    setState(() => _notified = true);
    final isRTL = context.isRTL;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'تم إرسال إشعار فوري إلى الطبيب المناوب.\nعبر الواتساب والرسائل النصية'
              : 'Incident dispatch sent to on-duty physician.\nNotified via SMS & WhatsApp',
        ),
      ),
    );
    widget.onNotify?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    if (widget.status == 'approved') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF15803D), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.check, size: 20, color: Color(0xFF15803D)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? 'معتمد من طبيب المدرسة' : 'Medication Approved',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRTL
                            ? 'تم الاعتماد بواسطة: د. ${widget.approvedBy} · ترخيص رَقَم: ${widget.licenseNumber} · في ${widget.approvedAt}'
                            : 'Approved by ${widget.approvedBy} · License: ${widget.licenseNumber} · On ${widget.approvedAt}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFD1FAE5)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.lock, size: 14, color: Color(0xFF15803D)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isRTL
                        ? 'هذا السجل دائم ومقفل قانونياً ولا يمكن تعديله.'
                        : 'This record is permanent and locked against modification.',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // PENDING state
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.clock, size: 20, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRTL ? '⏳ بانتظار موافقة الطبيب' : '⏳ Awaiting Physician Approval',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isRTL
                          ? 'لا يمكن إعطاء هذا الدواء للطالب قبل الحصول على موافقة الطبيب المناوب.'
                          : 'Medication cannot be administered until approved by the school physician.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _notified ? null : _handleNotify,
              style: OutlinedButton.styleFrom(
                backgroundColor: _notified ? const Color(0xFFFEF3C7) : Colors.white,
                side: BorderSide(
                  color: _notified ? Colors.transparent : const Color(0xFFF59E0B),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                disabledForegroundColor: const Color(0xFFB45309),
              ),
              icon: const Icon(LucideIcons.mail, size: 16, color: Color(0xFFB45309)),
              label: Text(
                _notified
                    ? (isRTL ? 'تم إرسال الإشعار بالطوارئ' : 'Physician Notified')
                    : (isRTL ? 'إرسال إشعار عاجل للطبيب المناوب' : 'Notify On-Duty Physician'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
