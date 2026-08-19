import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class EmergencyEscalationScreen extends StatefulWidget {
  const EmergencyEscalationScreen({super.key});

  @override
  State<EmergencyEscalationScreen> createState() =>
      _EmergencyEscalationScreenState();
}

class _EmergencyEscalationScreenState extends State<EmergencyEscalationScreen> {
  String _callStatus = 'calling'; // calling | ended
  final TextEditingController _decisionLog = TextEditingController();

  @override
  void initState() {
    super.initState();
    _decisionLog.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _decisionLog.dispose();
    super.dispose();
  }

  void _handleLogDecision() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.go('/nurse/clinic');
    });
  }

  @override
  Widget build(BuildContext context) {
    final calling = _callStatus == 'calling';
    return ColoredBox(
      color: SchooKeepColors.error,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 44),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: Column(
                  children: [
                    _phoneIcon(),
                    const SizedBox(height: 32),
                    Text(
                      calling
                          ? context.tr(en: 'Calling Parent', ar: 'جاري الاتصال بولي الأمر...')
                          : context.tr(en: 'Call Ended', ar: 'انتهت المكالمة'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      calling
                          ? context.tr(en: 'No Response Received', ar: 'لم يتم استلام رد من ولي الأمر')
                          : context.tr(en: 'Parent did not respond', ar: 'لم يجب ولي الأمر على المكالمة'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.tr(
                          en: 'Automatic emergency call initiated at 10:32 AM · Maya Chen · Playground incident',
                          ar: 'تم بدء الاتصال التلقائي في 10:32 AM · مايا تشن · حادثة الملعب المدرسي',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    if (calling) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _WhiteDot(),
                          SizedBox(width: 8),
                          _WhiteDot(),
                          SizedBox(width: 8),
                          _WhiteDot(),
                        ],
                      ),
                      const SizedBox(height: 48),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                setState(() => _callStatus = 'ended'),
                            child: Text(
                              context.tr(en: 'End Call', ar: 'إنهاء المكالمة'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: SchooKeepColors.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!calling) _actionSheet(context),
          ],
        ),
      ),
    );
  }

  Widget _phoneIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        LucideIcons.phone,
        size: 40,
        color: SchooKeepColors.error,
      ),
    );
  }

  Widget _actionSheet(BuildContext context) {
    final enabled = _decisionLog.text.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: AccentCard(
              background: SchooKeepColors.amberBg,
              accentColor: SchooKeepColors.warning,
              accentWidth: 4,
              radius: 12,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(en: 'Action Required', ar: 'الإجراء المطلـوب من الممرض/ة'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.amberText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      en: 'You may now proceed on your professional judgment. Document your decision below.',
                      ar: 'يمكنك الآن التصرف بناءً على تقييمك السريري المهني. يرجى توثيق القرار الطبي أدناه.',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: SchooKeepColors.amberText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Decision Log *', ar: 'توثيق القرار والتصرف الطبي *'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _decisionLog,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: context.tr(
                      en: 'Document your professional decision and next steps...',
                      ar: 'أدخل تفاصيل التقييم والقرار الطبي والخطوات التالية...',
                    ),
                    hintStyle: const TextStyle(
                      color: SchooKeepColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: SchooKeepColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: SchooKeepColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: SchooKeepColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    en: 'This decision will be permanently logged with timestamp',
                    ar: 'سيتم توثيق هذا القرار في سجل التدقيق الطبي مع الطابع الزمني المعتمد',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: SchooKeepColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.error,
                disabledBackgroundColor: SchooKeepColors.error.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: enabled ? _handleLogDecision : null,
              child: Text(
                context.tr(en: 'Log Decision', ar: 'اعتماد وتوثيق القرار'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteDot extends StatelessWidget {
  const _WhiteDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
