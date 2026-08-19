import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/sms_transaction.dart';
import '../../../data/repositories/sms_wallet_repository.dart';
import '../cubit/sms_wallet_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

class PrincipalSmsWalletScreen extends StatelessWidget {
  const PrincipalSmsWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmsWalletCubit(sl<SmsWalletRepository>()),
      child: const _PrincipalSmsWalletView(),
    );
  }
}

class _PrincipalSmsWalletView extends StatefulWidget {
  const _PrincipalSmsWalletView();

  @override
  State<_PrincipalSmsWalletView> createState() => _PrincipalSmsWalletViewState();
}

class _PrincipalSmsWalletViewState extends State<_PrincipalSmsWalletView> {
  final _topUpAmount = TextEditingController();

  @override
  void dispose() {
    _topUpAmount.dispose();
    super.dispose();
  }

  void _reload() => context.read<SmsWalletCubit>().load();

  Future<void> _handleTopUp() async {
    final credits = int.tryParse(_topUpAmount.text.trim());
    if (credits == null || credits <= 0) return;
    final ok = await context.read<SmsWalletCubit>().topup(credits);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.tr(
          en: 'Added $credits credits to your wallet',
          ar: 'تمت إضافة $credits رصيد إضافي إلى المحفظة',
        )),
      ));
      setState(() => _topUpAmount.clear());
    }
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: context.tr(en: 'SMS Wallet', ar: 'محفظة الرسائل النصية والواتساب'),
      onBack: () => context.safeBack(),
      body: BlocBuilder<SmsWalletCubit, DataState<SmsWalletData>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _errorBanner(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
      ),
    );
  }

  Widget _content(BuildContext context, SmsWalletData data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _balanceCard(context, data.balanceCredits),
          const SizedBox(height: 16),
          _usageChart(context),
          const SizedBox(height: 16),
          _topUpCard(context),
          const SizedBox(height: 16),
          _transactionHistory(context, data.transactions),
        ],
      ),
    );
  }

  Widget _errorBanner(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.error),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(error,
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.error, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SchooKeepButton(
            label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
            fullWidth: false,
            onPressed: _reload,
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(BuildContext context, int credits) {
    final low = credits < 50;
    final color = low ? SchooKeepColors.error : SchooKeepColors.accent;
    final bg = low ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.messageCircle, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Current Balance', ar: 'الرصيد الحالي'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(en: '$credits credits', ar: '$credits رصيد'),
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(en: '≈ $credits messages remaining', ar: 'متبقي ما يقارب $credits رسالة نصية'),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _usageChart(BuildContext context) {
    final dailyUsage = <_DayUsage>[
      _DayUsage(context.tr(en: 'Mon', ar: 'الإثنين'), 2, 15, 8),
      _DayUsage(context.tr(en: 'Tue', ar: 'الثلاثاء'), 0, 22, 12),
      _DayUsage(context.tr(en: 'Wed', ar: 'الأربعاء'), 1, 18, 10),
      _DayUsage(context.tr(en: 'Thu', ar: 'الخميس'), 0, 24, 14),
      _DayUsage(context.tr(en: 'Fri', ar: 'الجمعة'), 3, 20, 11),
      _DayUsage(context.tr(en: 'Sat', ar: 'السبت'), 0, 5, 2),
      _DayUsage(context.tr(en: 'Sun', ar: 'الأحد'), 0, 3, 1),
    ];
    final maxTotal = dailyUsage.map((d) => d.emergency + d.routine + d.reminder).reduce((a, b) => a > b ? a : b);

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Last 7 Days Usage', ar: 'استهلاك آخر 7 أيام'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          for (final d in dailyUsage) _usageRow(d, maxTotal),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(SchooKeepColors.error, context.tr(en: 'Emergency', ar: 'طوارئ')),
              const SizedBox(width: 12),
              _Legend(SchooKeepColors.primary, context.tr(en: 'Routine', ar: 'روتينية')),
              const SizedBox(width: 12),
              _Legend(SchooKeepColors.warning, context.tr(en: 'Reminder', ar: 'تذكير')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _usageRow(_DayUsage d, int maxTotal) {
    final total = d.emergency + d.routine + d.reminder;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 48,
            child: Text(d.day, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (d.emergency > 0) _bar(SchooKeepColors.error, d.emergency / maxTotal),
                  if (d.emergency > 0) const SizedBox(width: 2),
                  if (d.routine > 0) _bar(SchooKeepColors.primary, d.routine / maxTotal),
                  if (d.routine > 0) const SizedBox(width: 2),
                  if (d.reminder > 0) _bar(SchooKeepColors.warning, d.reminder / maxTotal),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text('$total',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _bar(Color color, double heightFactor) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: heightFactor.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topUpCard(BuildContext context) {
    final enabled = _topUpAmount.text.isNotEmpty;
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Add Funds', ar: 'شحن رصيد المحفظة'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _topUpAmount,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: context.tr(en: 'Enter credits', ar: 'أدخل عدد النقاط'),
                      hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: enabled ? SchooKeepColors.primary : const Color(0xFFE2E8F0),
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: enabled ? _handleTopUp : null,
                  child: Text(
                    context.tr(en: 'Add funds', ar: 'إضافة'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: enabled ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final amount in const [50, 100, 250, 500]) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _topUpAmount.text = amount.toString()),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                      child: Text('$amount',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    ),
                  ),
                ),
                if (amount != 500) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionHistory(BuildContext context, List<SmsTransaction> transactions) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Transaction History', ar: 'سجل المعاملات والشحن'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.tr(en: 'No transactions yet', ar: 'لا توجد معاملات مسجلة بعد'),
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
              ),
            )
          else
            for (int i = 0; i < transactions.length; i++)
              _txRow(context, transactions[i], i < transactions.length - 1),
        ],
      ),
    );
  }

  Widget _txRow(BuildContext context, SmsTransaction tx, bool divider) {
    final isTopup = tx.type == 'topup';
    final title = tx.description ?? (isTopup ? context.tr(en: 'Top-up', ar: 'شحن رصيد') : context.tr(en: 'SMS charge', ar: 'خصم رسائل نصية'));
    final amount = '${isTopup ? '+' : '-'}${tx.credits} ${context.tr(en: 'credits', ar: 'رصيد')}';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                Text(_formatDate(tx.createdAt),
                    style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isTopup ? SchooKeepColors.accent : SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
      ],
    );
  }
}

class _DayUsage {
  const _DayUsage(this.day, this.emergency, this.routine, this.reminder);
  final String day;
  final int emergency;
  final int routine;
  final int reminder;
}
