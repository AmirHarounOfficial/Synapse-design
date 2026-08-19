import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/weather_advisory.dart';
import '../../../data/repositories/system_repository.dart';
import '../cubit/weather_advisory_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

class PrincipalWeatherAdvisoryScreen extends StatelessWidget {
  const PrincipalWeatherAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherAdvisoryCubit(sl<SystemRepository>()),
      child: const _PrincipalWeatherAdvisoryView(),
    );
  }
}

class _PrincipalWeatherAdvisoryView extends StatefulWidget {
  const _PrincipalWeatherAdvisoryView();

  @override
  State<_PrincipalWeatherAdvisoryView> createState() => _PrincipalWeatherAdvisoryViewState();
}

class _PrincipalWeatherAdvisoryViewState extends State<_PrincipalWeatherAdvisoryView> {
  bool _showForm = false;
  bool _busy = false;
  String _advisoryType = 'haboob';
  final Set<String> _affectedGroups = {'asthma'};
  late final TextEditingController _message;
  bool _sendToStaff = true;
  bool _sendToAffectedParents = true;
  bool _sendToAllParents = false;
  bool _sendWhatsApp = true;

  static const _aqiBg = Color(0xFFFEE2E2);
  static const _aqiText = Color(0xFFDC2626);
  static const _aqiBorder = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _message = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_message.text.isEmpty) {
      _message.text = context.tr(
        en: 'Due to an active Haboob (sandstorm) warning from UAE NCM, students with respiratory conditions must remain indoors. Outdoor recess suspended.',
        ar: 'نظراً لتنبيه العواصف الرملية النشطة من المركز الوطني للأرصاد، يرجى إبقاء الطلاب المصابين بأمراض تنفسية داخل المبنى وتعليق الأنشطة الخارجية.',
      );
    }
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _handleIssueAdvisory() async {
    final ok = await _confirm(context.tr(
      en: 'Issue advisory and send alerts to all selected recipients?',
      ar: 'هل ترغب في إصدار التنبيه وإرسال الإشعارات إلى جميع الجهات المحددة؟',
    ));
    if (!ok || !mounted || _busy) return;
    setState(() => _busy = true);
    final error = await context.read<WeatherAdvisoryCubit>().issue(
          kind: _advisoryType,
          severity: 'unhealthy',
          message: _message.text.trim(),
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (error == null) _showForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? context.tr(
        en: 'Advisory issued successfully. Alerts sent to staff and parents.',
        ar: 'تم إصدار التنبيه بنجاح وإرسال الإشعارات للكادر وأولياء الأمور.',
      )),
    ));
  }

  Future<void> _handleLiftAdvisory() async {
    final ok = await _confirm(context.tr(
      en: 'Lift the current advisory? All recipients will be notified.',
      ar: 'هل ترغب في إلغاء التنبيه الحالي؟ سيتم إشعار كافة الأطراف.',
    ));
    if (!ok || !mounted || _busy) return;
    setState(() => _busy = true);
    final error = await context.read<WeatherAdvisoryCubit>().lift();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? context.tr(
        en: 'Advisory lifted. Notifications sent.',
        ar: 'تم إلغاء التنبيه وإرسال الإشعارات.',
      )),
    ));
  }

  Future<bool> _confirm(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr(en: 'Cancel', ar: 'إلغاء')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr(en: 'OK', ar: 'موافق')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: context.tr(en: 'Weather Advisory', ar: 'تنبيهات الأحوال الجوية'),
      onBack: () => context.safeBack(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<WeatherAdvisoryCubit, DataState<WeatherAdvisory?>>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _currentConditions(context),
                const SizedBox(height: 16),
                ..._stateSection(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _stateSection(BuildContext context, DataState<WeatherAdvisory?> state) {
    switch (state) {
      case DataLoading():
        return const [Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))];
      case DataError(:final message):
        return [_errorCard(context, message)];
      case DataLoaded(:final data):
        final active = data != null;
        return [
          active ? _activeCard(context, data) : _noAdvisoryCard(context),
          if (_showForm && !active) ...[
            const SizedBox(height: 16),
            _advisoryTypeCard(context),
            const SizedBox(height: 16),
            _affectedGroupsCard(context),
            const SizedBox(height: 16),
            _messageCard(context),
            const SizedBox(height: 16),
            _sendToCard(context),
            const SizedBox(height: 16),
            _issueButton(context),
          ],
        ];
    }
  }

  Widget _errorCard(BuildContext context, String message) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 12),
          SchooKeepButton(
            label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
            fullWidth: false,
            onPressed: () => context.read<WeatherAdvisoryCubit>().load(),
          ),
        ],
      ),
    );
  }

  Widget _currentConditions(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Current Conditions', ar: 'الأحوال الجوية الحالية'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr(en: 'Temperature', ar: 'درجة الحرارة'), style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 2),
                    const Text('42°C',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr(en: 'AQI Score', ar: 'مؤشر جودة الهواء'), style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _aqiBg, borderRadius: BorderRadius.circular(999)),
                      child: const Text('156',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _aqiText)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _aqiBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _aqiBorder),
            ),
            child: Text(
              context.tr(
                en: 'Haboob / Active Sandstorm Advisory (Source: UAE NCM)',
                ar: 'عاصفة رملية نشطة / تنبيه من المركز الوطني للأرصاد الإماراتي',
              ),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _aqiText),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr(en: 'Opening UAE NCM forecast…', ar: 'جاري فتح نشرة الأرصاد الجوية...'))),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr(en: 'View full forecast', ar: 'عرض النشرة الجوية الكاملة'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.externalLink, size: 16, color: SchooKeepColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noAdvisoryCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.cloudOff, size: 20, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'No active advisory', ar: 'لا يوجد تنبيه جوي نشط'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
              ),
            ],
          ),
          if (!_showForm) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => setState(() => _showForm = true),
                child: Text(
                  context.tr(en: 'Issue Advisory', ar: 'إصدار تنبيه جديد'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _activeCard(BuildContext context, WeatherAdvisory advisory) {
    final since = (advisory.startsAt ?? advisory.createdAt)?.toLocal();
    final sinceLabel = since != null
        ? '${since.hour == 0 ? 12 : (since.hour > 12 ? since.hour - 12 : since.hour)}:'
            '${since.minute.toString().padLeft(2, '0')} ${since.hour < 12 ? 'AM' : 'PM'}'
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sinceLabel != null
                          ? context.tr(en: '⚠ Advisory Active since $sinceLabel', ar: '⚠ تنبيه جوي نشط منذ $sinceLabel')
                          : context.tr(en: '⚠ Advisory Active', ar: '⚠ تنبيه جوي نشط حالياً'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      advisory.message.isNotEmpty
                          ? advisory.message
                          : context.tr(en: 'All staff and affected parents have been notified', ar: 'تم إشعار الكادر المدرسي وأولياء الأمور المعنيين'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: SchooKeepColors.warning),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _busy ? null : _handleLiftAdvisory,
              child: Text(
                context.tr(en: 'Lift advisory', ar: 'إلغاء التنبيه الحالي'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF92400E)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _advisoryTypeCard(BuildContext context) {
    final advisoryTypes = <(String, String)>[
      ('haboob', context.tr(en: 'Haboob (Sandstorm)', ar: 'عاصفة رملية (هبوب)')),
      ('aqi-dust', context.tr(en: 'AQI / Dust', ar: 'غبار وتدني جودة الهواء')),
      ('heat', context.tr(en: 'Extreme Heat', ar: 'ارتفاع حرارة شديد')),
      ('flooding', context.tr(en: 'Flooding / Rain', ar: 'أمطار وسيول')),
      ('other', context.tr(en: 'Other', ar: 'أخرى')),
    ];

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Advisory Type', ar: 'نوع التنبيه الجوي'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in advisoryTypes)
                GestureDetector(
                  onTap: () => setState(() => _advisoryType = t.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _advisoryType == t.$1 ? SchooKeepColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(t.$2,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _advisoryType == t.$1 ? Colors.white : SchooKeepColors.textSecondary)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _affectedGroupsCard(BuildContext context) {
    final affectedGroupOptions = <(String, String)>[
      ('asthma', context.tr(en: 'Asthma / Respiratory students', ar: 'طلاب الربو والأمراض التنفسية')),
      ('all-students', context.tr(en: 'All students', ar: 'جميع الطلاب')),
      ('outdoor', context.tr(en: 'Outdoor activities', ar: 'الأنشطة الرياضية والفسحة الخارجية')),
      ('bus', context.tr(en: 'Bus routes', ar: 'حافلات النقل المدرسي')),
    ];

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Affected Groups', ar: 'الفئات المتأثرة'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 8),
          for (final g in affectedGroupOptions)
            _checkboxRow(g.$2, _affectedGroups.contains(g.$1), () {
              setState(() {
                if (_affectedGroups.contains(g.$1)) {
                  _affectedGroups.remove(g.$1);
                } else {
                  _affectedGroups.add(g.$1);
                }
              });
            }),
        ],
      ),
    );
  }

  Widget _messageCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Advisory Message', ar: 'نص رسالة التنبيه'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _message,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: SchooKeepColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendToCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Send Alerts To', ar: 'إرسال الإشعارات إلى'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _checkboxRow(context.tr(en: 'All staff', ar: 'جميع الكادر المدرسي'), _sendToStaff, () => setState(() => _sendToStaff = !_sendToStaff)),
          _checkboxRow(context.tr(en: 'Affected parents only', ar: 'أولياء أمور الطلاب المعنيين فقط'), _sendToAffectedParents,
              () => setState(() => _sendToAffectedParents = !_sendToAffectedParents)),
          _checkboxRow(context.tr(en: 'All parents', ar: 'جميع أولياء الأمور'), _sendToAllParents, () => setState(() => _sendToAllParents = !_sendToAllParents)),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _whatsAppRow(context),
        ],
      ),
    );
  }

  Widget _issueButton(BuildContext context) {
    final enabled = _affectedGroups.isNotEmpty && _message.text.isNotEmpty && !_busy;
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: enabled ? SchooKeepColors.error : const Color(0xFFE2E8F0), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: enabled ? _handleIssueAdvisory : null,
        child: _busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(
                context.tr(en: 'Issue Advisory & Send Alerts', ar: 'إصدار التنبيه وإرسال الإشعارات'),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: enabled ? SchooKeepColors.error : const Color(0xFF94A3B8)),
              ),
      ),
    );
  }

  Widget _checkboxRow(String label, bool checked, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            _checkbox(checked),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkbox(bool checked) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? SchooKeepColors.primary : SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: checked ? SchooKeepColors.primary : const Color(0xFFD1D5DB)),
      ),
      child: checked ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
    );
  }

  Widget _whatsAppRow(BuildContext context) {
    final isRTL = context.isRTL;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
            child: const Icon(LucideIcons.messageCircle, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WhatsApp',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFECFEFF), borderRadius: BorderRadius.circular(4)),
                  child: Text('🇦🇪 ${isRTL ? 'موصى به للإمارات' : 'Recommended for UAE'}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0E7490))),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _sendWhatsApp = !_sendWhatsApp),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(4),
              alignment: _sendWhatsApp ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              decoration: BoxDecoration(
                color: _sendWhatsApp ? SchooKeepColors.primary : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(
                width: 16,
                height: 16,
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
