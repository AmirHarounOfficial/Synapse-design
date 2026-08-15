import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';
import '../cubit/protocol_review_cubit.dart';

/// Ported from `MedicationProtocolReview.tsx`, now wired to the API. Reviews a
/// nurse's proposed medication protocol (`GET /medications/{id}`) with approve /
/// approve-with-modification / request-info / decline flows and a signature PIN
/// modal (demo PIN 1234 or 9999). Approve/decline hit the action endpoints
/// (`POST /medications/{id}/approve|decline`).
///
/// Note: the modification fields and "request more info" remain client-side as
/// in the source — the medications cluster has no update-on-approve or
/// clarification endpoint, so approving a modification simply calls approve.
class MedicationProtocolReviewScreen extends StatelessWidget {
  const MedicationProtocolReviewScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    final medId = int.tryParse(id ?? '') ?? 0;
    return BlocProvider(
      create: (_) => ProtocolReviewCubit(sl<MedicationRepository>(), medId),
      child: const _ProtocolReviewView(),
    );
  }
}

class _ProtocolReviewView extends StatefulWidget {
  const _ProtocolReviewView();

  @override
  State<_ProtocolReviewView> createState() => _ProtocolReviewViewState();
}

class _ProtocolReviewViewState extends State<_ProtocolReviewView> {
  bool _showModifications = false;
  bool _showDeclineReason = false;
  bool _isApproved = false;
  String? _approvedRecord;

  final TextEditingController _modDose = TextEditingController();
  final TextEditingController _modTimes = TextEditingController();
  final TextEditingController _declineReason = TextEditingController();
  bool _modInitialized = false;

  @override
  void dispose() {
    _modDose.dispose();
    _modTimes.dispose();
    _declineReason.dispose();
    super.dispose();
  }

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? SchooKeepColors.error : SchooKeepColors.physicianTeal,
      ),
    );
  }

  void _handleApprove() {
    setState(() => _showDeclineReason = false);
    _showPinPrompt();
  }

  Future<void> _handleDeclineSubmit() async {
    final isRTL = context.isRTL;
    if (_declineReason.text.trim().isEmpty) {
      _toast(isRTL ? 'يرجى تحديد سبب الرفض' : 'Please provide a reason for declining.', error: true);
      return;
    }
    final error = await context.read<ProtocolReviewCubit>().decline();
    if (!mounted) return;
    if (error != null) {
      _toast(error, error: true);
      return;
    }
    _toast(isRTL ? 'تم رفض البروتوكول وإعادته للممرضة' : 'Protocol declined and returned to clinic.');
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) context.go('/physician/dashboard');
    });
  }

  void _showPinPrompt() {
    final isRTL = context.isRTL;
    final pinController = TextEditingController();
    var pinError = false;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: SchooKeepColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isRTL ? 'تأكيد التوقيع الرقمي' : 'Verify Clinical Signature',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    isRTL
                        ? 'أدخل رمز PIN الخاص بالطبيب للموافقة على السجل الطبي وإقفاله.'
                        : 'Enter your 4-digit signature PIN to authorize and stamp this record.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, letterSpacing: 8),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••',
                      filled: true,
                      fillColor: SchooKeepColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: pinError ? SchooKeepColors.error : SchooKeepColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: pinError ? SchooKeepColors.error : SchooKeepColors.physicianTeal, width: 2),
                      ),
                    ),
                  ),
                  Text(isRTL ? '(رمز الدخول التجريبي: 1234 أو 9999)' : '(Demo code: 1234 or 9999)',
                      style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: SchooKeepColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(isRTL ? 'إلغاء' : 'Cancel',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: SchooKeepColors.physicianTeal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              final pin = pinController.text;
                              if (pin == '1234' || pin == '9999') {
                                Navigator.of(dialogContext).pop();
                                _onPinVerified();
                              } else {
                                setDialogState(() => pinError = true);
                                pinController.clear();
                                _toast(isRTL ? 'رمز PIN غير صحيح' : 'Incorrect verification PIN.', error: true);
                              }
                            },
                            child: Text(isRTL ? 'توقيع السجل' : 'Sign Record',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(pinController.dispose);
  }

  Future<void> _onPinVerified() async {
    final isRTL = context.isRTL;
    // The PIN is the local clinical signature; the actual approval is the API call.
    final error = await context.read<ProtocolReviewCubit>().approve();
    if (!mounted) return;
    if (error != null) {
      _toast(error, error: true);
      return;
    }
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final stamp = isRTL
        ? '✓ معتمد من د. أمينة الهاشمي · ترخيص DHA MD-4029 · بتاريخ $dateStr الساعة $timeStr'
        : '✓ Approved by Dr. Amina Al-Hashimi · DHA MD-4029 · $dateStr at $timeStr';
    setState(() {
      _isApproved = true;
      _approvedRecord = stamp;
    });
    _toast(isRTL ? 'تم توقيع واعتماد البروتوكول' : 'Protocol approved and signed!');
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) context.go('/physician/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return BlocBuilder<ProtocolReviewCubit, DataState<Medication>>(
      builder: (context, state) {
        final title = switch (state) {
          DataLoaded(:final data) => data.name,
          _ => isRTL ? 'مراجعة البروتوكول' : 'Protocol Review',
        };
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            onBack: () => context.go('/physician/dashboard'),
            centerTitle: true,
            titleWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isRTL ? 'مراجعة البروتوكول' : 'Protocol Review',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                Text(title, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          body: switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorView(context, message, isRTL),
            DataLoaded(:final data) => _content(context, data, isRTL),
          },
        );
      },
    );
  }

  Widget _errorView(BuildContext context, String message, bool isRTL) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: isRTL ? 'إعادة المحاولة' : 'Retry',
              fullWidth: false,
              onPressed: () => context.read<ProtocolReviewCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Medication med, bool isRTL) {
    if (!_modInitialized) {
      _modDose.text = med.dosage ?? '';
      _modTimes.text = med.doses.map((d) => d.scheduledTime ?? '').where((t) => t.isNotEmpty).join(', ');
      _modInitialized = true;
    }
    // Reflect an already-approved record loaded from the API.
    final apiApproved = med.isApproved || _isApproved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _noticeBanner(isRTL),
        const SizedBox(height: 16),
        _studentCard(med, isRTL),
        const SizedBox(height: 16),
        _proposalCard(med, isRTL),
        if (apiApproved) ...[
          const SizedBox(height: 16),
          _approvedStamp(isRTL, med),
        ],
        if (!apiApproved) ...[
          const SizedBox(height: 16),
          _actions(isRTL),
        ],
      ],
    );
  }

  Widget _noticeBanner(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 20, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isRTL
                  ? 'موافقة الطبيب إلزامية قبل إعطاء هذا الدواء بالمدرسة بموجب لوائح هيئة الصحة ST-22 وقانون حماية البيانات الشخصية الإماراتي.'
                  : 'Physician approval is required before this medication can be administered per DHA/HRS/HPSD/ST-22 and UAE PDPL compliance.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Widget _studentCard(Medication med, bool isRTL) {
    final studentLabel = isRTL ? 'الطالب رقم ${med.studentId}' : 'Student #${med.studentId}';
    return SchooKeepCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SchooKeepColors.physicianTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(_initials(med.name),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentLabel,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                    (med.prescribedBy ?? '').isNotEmpty
                        ? (isRTL ? 'وصفها: ${med.prescribedBy}' : 'Prescribed by ${med.prescribedBy}')
                        : (isRTL ? 'بانتظار المراجعة' : 'Awaiting review'),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proposalCard(Medication med, bool isRTL) {
    final times = med.doses.map((d) => d.scheduledTime).whereType<String>().toList();
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'الدواء المقترح' : 'PROPOSED MEDICATION PROTOCOL',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(med.displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'الجرعة المقترحة' : 'Proposed Dose',
                        style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(med.dosage ?? '—',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'أوقات الإعطاء' : 'Scheduled Times',
                        style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (times.isEmpty)
                          Text(isRTL ? 'حسب الحاجة' : 'As needed',
                              style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary))
                        else
                          for (final t in times)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(t,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((med.instructions ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.fileText, size: 20, color: SchooKeepColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(med.instructions!,
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.lock, size: 14, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  (med.prescribedBy ?? '').isNotEmpty
                      ? (isRTL ? 'مقدم من: ${med.prescribedBy}' : 'Proposed by: ${med.prescribedBy}')
                      : (isRTL ? 'مقدم من الممرضة' : 'Proposed by clinic nurse'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _approvedStamp(bool isRTL, Medication med) {
    final stamp = _approvedRecord ??
        (isRTL
            ? '✓ تم الاعتماد بتاريخ ${med.approvedAt ?? '—'}'
            : '✓ Approved on ${med.approvedAt ?? '—'}');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.halalGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.halalGreen),
              const SizedBox(width: 8),
              Text(isRTL ? 'تم اعتماد البروتوكول بنجاح' : 'Protocol Approved & Locked',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.halalGreen)),
            ],
          ),
          const SizedBox(height: 8),
          Text(stamp,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534), height: 1.5)),
        ],
      ),
    );
  }

  Widget _actions(bool isRTL) {
    if (_showModifications) return _modificationForm(isRTL);
    if (_showDeclineReason) return _declineForm(isRTL);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: SchooKeepColors.physicianTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _handleApprove,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.shieldCheck, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(isRTL ? 'اعتماد البروتوكول كما هو مقترح' : 'Approve as Proposed',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: SchooKeepColors.surface,
              side: const BorderSide(color: SchooKeepColors.physicianTeal, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(() => _showModifications = true),
            child: Text(isRTL ? 'اعتماد مع تعديل المقترح' : 'Approve with Modification',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: SchooKeepColors.surface,
                    side: const BorderSide(color: SchooKeepColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _toast(isRTL ? 'تم إرسال طلب التوضيح للممرضة' : 'Clarification request sent to clinic nurse.');
                    context.go('/physician/dashboard');
                  },
                  child: Text(isRTL ? 'طلب معلومات إضافية' : 'Request More Info',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: SchooKeepColors.surface,
                    side: const BorderSide(color: SchooKeepColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _showDeclineReason = true),
                  child: Text(isRTL ? 'رفض البروتوكول' : 'Decline Protocol',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _modificationForm(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'تعديل جرعات وأوقات البروتوكول' : 'Clinical Modification Fields',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
          const SizedBox(height: 16),
          _fieldLabel(isRTL ? 'تعديل الجرعة' : 'Modify Dose'),
          const SizedBox(height: 4),
          _textField(_modDose),
          const SizedBox(height: 12),
          _fieldLabel(isRTL ? 'تعديل الأوقات' : 'Modify Times'),
          const SizedBox(height: 4),
          _textField(_modTimes),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: SchooKeepColors.surface,
                      side: const BorderSide(color: SchooKeepColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _showModifications = false),
                    child: Text(isRTL ? 'إلغاء' : 'Cancel',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.physicianTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _handleApprove,
                    child: Text(isRTL ? 'توقيع واعتماد التعديل' : 'Sign & Approve Mod',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _declineForm(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'سبب رفض البروتوكول الطبي' : 'Protocol Declination Reason',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
          const SizedBox(height: 16),
          _fieldLabel(isRTL ? 'سبب الرفض (إلزامي)' : 'Reason (Mandatory)'),
          const SizedBox(height: 6),
          TextField(
            controller: _declineReason,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
            decoration: InputDecoration(
              hintText: isRTL
                  ? 'مثال: التشخيص غير واضح، جرعة غير مطابقة...'
                  : 'e.g., Clinical report unclear, dosage exceeds guidelines...',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: SchooKeepColors.surface,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.physicianTeal),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: SchooKeepColors.surface,
                      side: const BorderSide(color: SchooKeepColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _showDeclineReason = false),
                    child: Text(isRTL ? 'إلغاء' : 'Cancel',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _handleDeclineSubmit,
                    child: Text(isRTL ? 'تأكيد الرفض' : 'Confirm Decline',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) =>
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary));

  Widget _textField(TextEditingController controller) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: SchooKeepColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: SchooKeepColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: SchooKeepColors.physicianTeal),
          ),
        ),
      ),
    );
  }
}
