import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

/// Ported from `LowSupplyAlert.tsx`, now wired to the API. Supply alert screen
/// with an amber banner, alert card + supply progress bar, a notify-parent
/// action, medication details, and reorder information. When reached with a
/// [medicationId] query param, the supply count / medication details load from
/// the API (`GET /medications/{id}`); otherwise demo values are shown.
///
/// Note: the medications cluster exposes no "notify parent" endpoint, so that
/// action remains a local confirmation as in the source.
class LowSupplyAlertScreen extends StatefulWidget {
  const LowSupplyAlertScreen({super.key, this.medicationId});

  final int? medicationId;

  @override
  State<LowSupplyAlertScreen> createState() => _LowSupplyAlertScreenState();
}

class _LowSupplyAlertScreenState extends State<LowSupplyAlertScreen> {
  bool _parentNotified = false;
  String _notificationDate = '';

  final MedicationRepository _repo = sl<MedicationRepository>();
  Medication? _medication;

  @override
  void initState() {
    super.initState();
    final id = widget.medicationId;
    if (id != null) {
      _repo
          .show(id)
          .then((m) {
            if (mounted) setState(() => _medication = m);
          })
          .catchError((_) {
            // Fall back to demo values on failure.
          });
    }
  }

  int get _dosesRemaining => _medication?.supplyCount ?? 10;
  int get _totalDoses {
    final threshold = _medication?.lowSupplyThreshold;
    // Use 3x the low-supply threshold as a sensible "full" baseline when known.
    if (threshold != null && threshold > 0) return threshold * 3;
    return 30;
  }

  String get _medicationName =>
      _medication?.displayName ?? 'Methylphenidate 10mg';

  double get _supplyPercentage =>
      _totalDoses == 0 ? 0 : (_dosesRemaining / _totalDoses).clamp(0.0, 1.0);

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Overflow menu in the app bar — relevant supply-alert actions.
  void _handleMenu() {
    final medId = widget.medicationId;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              if (medId != null)
                ListTile(
                  leading: const Icon(LucideIcons.pill, size: 20, color: SchooKeepColors.primary),
                  title: const Text('View medication details',
                      style: TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/nurse/medications/$medId');
                  },
                ),
              ListTile(
                leading: const Icon(LucideIcons.bell, size: 20, color: SchooKeepColors.primary),
                title: const Text('Notify parent',
                    style: TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary)),
                enabled: !_parentNotified,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleNotifyParent();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _handleNotifyParent() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour < 12 ? 'AM' : 'PM';
    final hh = hour12.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final formatted =
        '${_months[now.month - 1]} ${now.day}, ${now.year} at $hh:$mm $period';
    setState(() {
      _notificationDate = formatted;
      _parentNotified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Maya Chen',
        centerTitle: true,
        onBack: () => context.go('/nurse/medications'),
        actions: [
          InkWell(
            onTap: _handleMenu,
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                LucideIcons.moreVertical,
                size: 24,
                color: SchooKeepColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _amberBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _alertCard(),
                const SizedBox(height: 24),
                _actionSection(),
                const SizedBox(height: 24),
                _medicationDetails(),
                const SizedBox(height: 24),
                _reorderInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amberBanner() {
    return Container(
      width: double.infinity,
      color: SchooKeepColors.warning,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Icon(LucideIcons.alertTriangle, size: 24, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Supply Alert',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard() {
    return AccentCard(
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  LucideIcons.alertTriangle,
                  size: 24,
                  color: SchooKeepColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Low supply of $_medicationName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.amberText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _detailRow('Current count:', '$_dosesRemaining doses'),
                    const SizedBox(height: 8),
                    _detailRow('Expected depletion:', 'May 24, 2026'),
                    const SizedBox(height: 8),
                    _detailRow('Expiry date:', 'June 15, 2026'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Supply Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.amberText,
                ),
              ),
              Text(
                '$_dosesRemaining of $_totalDoses doses',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.amberText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _supplyPercentage,
              minHeight: 8,
              backgroundColor: SchooKeepColors.amberChipBg,
              valueColor: const AlwaysStoppedAnimation<Color>(
                SchooKeepColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: SchooKeepColors.amberText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: SchooKeepColors.amberText,
          ),
        ),
      ],
    );
  }

  Widget _actionSection() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (!_parentNotified) ...[
            SchooKeepButton(
              label: 'Notify Parent',
              icon: LucideIcons.bell,
              onPressed: _handleNotifyParent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sends automatic supply alert to parent via SMS and app notification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: SchooKeepColors.textSecondary,
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: AccentCard(
                background: SchooKeepColors.greenChipBg,
                accentColor: SchooKeepColors.accent,
                accentWidth: 4,
                radius: 12,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        LucideIcons.checkCircle,
                        size: 20,
                        color: SchooKeepColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Parent Notified',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: SchooKeepColors.greenChipText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _notificationDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: SchooKeepColors.greenChipText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _medicationDetails() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medication Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow('Medication', _medicationName, divider: true),
          _infoRow(
            'Type',
            _medication?.endDate == null ? 'Permanent' : 'Temporary',
            divider: true,
          ),
          _infoRow(
            'Daily Doses',
            '${_medication?.doses.length ?? 1} dose(s)',
            divider: true,
          ),
          _infoRow(
            'Prescribing Physician',
            _medication?.prescribedBy ?? 'Dr. Rodriguez',
            divider: false,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {required bool divider}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: SchooKeepColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: SchooKeepColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reorderInfo() {
    return SizedBox(
      width: double.infinity,
      child: AccentCard(
        background: const Color(0xFFEFF6FF),
        accentColor: SchooKeepColors.primary,
        accentWidth: 4,
        radius: 12,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reorder Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Parents must coordinate with prescribing physician for refill authorization. School policy '
              'requires 7-day supply buffer.',
              style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
            ),
            const SizedBox(height: 12),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                children: [
                  TextSpan(
                    text: 'Recommended action: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: 'Notify parent at least 7 days before depletion',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
