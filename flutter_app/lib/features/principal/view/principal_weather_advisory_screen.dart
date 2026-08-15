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

/// Ported from `PrincipalWeatherAdvisory.tsx`, wired to `/weather-advisories`.
/// Shows current AQI conditions and an issue/lift advisory flow with a
/// recipient-selection form (incl. an inlined WhatsApp toggle row). "Issue"
/// POSTs a new active advisory; "Lift" PATCHes it inactive. The current-active
/// state is loaded from `GET /weather-advisories?active=1`. Recipient/channel
/// toggles drive the message only — the API has no per-recipient routing field.
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
  final _message = TextEditingController(
      text:
          'Due to an active Haboob (sandstorm) warning from UAE NCM, students with respiratory conditions must remain indoors. Outdoor recess suspended.');
  bool _sendToStaff = true;
  bool _sendToAffectedParents = true;
  bool _sendToAllParents = false;
  bool _sendWhatsApp = true;

  // AQI is "unhealthy" → red palette.
  static const _aqiBg = Color(0xFFFEE2E2);
  static const _aqiText = Color(0xFFDC2626);
  static const _aqiBorder = Color(0xFFDC2626);

  static const _advisoryTypes = <(String, String)>[
    ('haboob', 'Haboob (Sandstorm) / عاصفة رملية'),
    ('aqi-dust', 'AQI / Dust'),
    ('heat', 'Extreme Heat'),
    ('flooding', 'Flooding'),
    ('other', 'Other'),
  ];

  static const _affectedGroupOptions = <(String, String)>[
    ('asthma', 'Asthma students'),
    ('all-students', 'All students'),
    ('outdoor', 'Outdoor activities'),
    ('bus', 'Bus routes'),
  ];

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _handleIssueAdvisory() async {
    final ok = await _confirm('Issue advisory and send alerts to all selected recipients?');
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
      content: Text(error ?? 'Advisory issued successfully. Alerts sent to staff and parents.'),
    ));
  }

  Future<void> _handleLiftAdvisory() async {
    final ok = await _confirm('Lift the current advisory? All recipients will be notified.');
    if (!ok || !mounted || _busy) return;
    setState(() => _busy = true);
    final error = await context.read<WeatherAdvisoryCubit>().lift();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Advisory lifted. Notifications sent.'),
    ));
  }

  Future<bool> _confirm(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: 'Weather Advisory',
      onBack: () => context.safeBack(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<WeatherAdvisoryCubit, DataState<WeatherAdvisory?>>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _currentConditions(),
                const SizedBox(height: 16),
                ..._stateSection(state),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _stateSection(DataState<WeatherAdvisory?> state) {
    switch (state) {
      case DataLoading():
        return const [Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))];
      case DataError(:final message):
        return [_errorCard(message)];
      case DataLoaded(:final data):
        final active = data != null;
        return [
          active ? _activeCard(data) : _noAdvisoryCard(),
          if (_showForm && !active) ...[
            const SizedBox(height: 16),
            _advisoryTypeCard(),
            const SizedBox(height: 16),
            _affectedGroupsCard(),
            const SizedBox(height: 16),
            _messageCard(),
            const SizedBox(height: 16),
            _sendToCard(),
            const SizedBox(height: 16),
            _issueButton(),
          ],
        ];
    }
  }

  Widget _errorCard(String message) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 12),
          SchooKeepButton(
            label: 'Retry',
            fullWidth: false,
            onPressed: () => context.read<WeatherAdvisoryCubit>().load(),
          ),
        ],
      ),
    );
  }

  Widget _currentConditions() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Conditions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Temperature', style: TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                    SizedBox(height: 2),
                    Text('42°C',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AQI Score', style: TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
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
            child: const Text('Haboob / Active Sandstorm Advisory (Source: UAE NCM)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _aqiText)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening UAE NCM forecast…')),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View full forecast',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                SizedBox(width: 8),
                Icon(LucideIcons.externalLink, size: 16, color: SchooKeepColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noAdvisoryCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.cloudOff, size: 20, color: SchooKeepColors.textSecondary),
              SizedBox(width: 8),
              Text('No active advisory',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
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
                child: const Text('Issue Advisory',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _activeCard(WeatherAdvisory advisory) {
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
                    Text(sinceLabel != null ? '⚠ Advisory Active since $sinceLabel' : '⚠ Advisory Active',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                    const SizedBox(height: 4),
                    Text(
                        advisory.message.isNotEmpty
                            ? advisory.message
                            : 'All staff and affected parents have been notified',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF92400E))),
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
              child: const Text('Lift advisory',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF92400E))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _advisoryTypeCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Advisory Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _advisoryTypes)
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

  Widget _affectedGroupsCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Affected Groups',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          for (final g in _affectedGroupOptions)
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

  Widget _messageCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Advisory Message',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
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

  Widget _sendToCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Alerts To',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          _checkboxRow('All staff', _sendToStaff, () => setState(() => _sendToStaff = !_sendToStaff)),
          _checkboxRow('Affected parents only', _sendToAffectedParents,
              () => setState(() => _sendToAffectedParents = !_sendToAffectedParents)),
          _checkboxRow('All parents', _sendToAllParents, () => setState(() => _sendToAllParents = !_sendToAllParents)),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _whatsAppRow(),
        ],
      ),
    );
  }

  Widget _issueButton() {
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
            : Text('Issue Advisory & Send Alerts',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: enabled ? SchooKeepColors.error : const Color(0xFF94A3B8))),
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

  /// Inlined `WhatsAppToggleRow.tsx` — green WhatsApp glyph + UAE-recommended
  /// chip and a toggle switch.
  Widget _whatsAppRow() {
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
