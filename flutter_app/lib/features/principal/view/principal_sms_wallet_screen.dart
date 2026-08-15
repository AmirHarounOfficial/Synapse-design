import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/sms_transaction.dart';
import '../../../data/repositories/sms_wallet_repository.dart';
import '../cubit/sms_wallet_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalSMSWallet.tsx`, wired to [SmsWalletCubit]
/// (`GET /sms-wallet`, `POST /sms-wallet/topup`). Balance card (color-coded by
/// level), a 7-day usage chart, top-up controls, and live transaction history.
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

  // Static 7-day usage breakdown (no per-day series in the API yet) — kept to
  // preserve the ported chart design.
  static const _dailyUsage = <_DayUsage>[
    _DayUsage('Mon', 2, 15, 8),
    _DayUsage('Tue', 0, 22, 12),
    _DayUsage('Wed', 1, 18, 10),
    _DayUsage('Thu', 0, 24, 14),
    _DayUsage('Fri', 3, 20, 11),
    _DayUsage('Sat', 0, 5, 2),
    _DayUsage('Sun', 0, 3, 1),
  ];

  int get _maxTotal =>
      _dailyUsage.map((d) => d.emergency + d.routine + d.reminder).reduce((a, b) => a > b ? a : b);

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added $credits credits to your wallet')));
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
      title: 'SMS Wallet',
      onBack: () => context.safeBack(),
      body: BlocBuilder<SmsWalletCubit, DataState<SmsWalletData>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _errorBanner(message),
            DataLoaded(:final data) => _content(data),
          };
        },
      ),
    );
  }

  Widget _content(SmsWalletData data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _balanceCard(data.balanceCredits),
          const SizedBox(height: 16),
          _usageChart(),
          const SizedBox(height: 16),
          _topUpCard(),
          const SizedBox(height: 16),
          _transactionHistory(data.transactions),
        ],
      ),
    );
  }

  Widget _errorBanner(String error) {
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
          SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: _reload),
        ],
      ),
    );
  }

  Widget _balanceCard(int credits) {
    // Color-code the balance by level: low balances warn in red.
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
              const Text('Current Balance',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text('$credits credits',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text('≈ $credits messages remaining',
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _usageChart() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last 7 Days Usage',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          for (final d in _dailyUsage) _usageRow(d),
          const SizedBox(height: 12),
          const Row(
            children: [
              _Legend(SchooKeepColors.error, 'Emergency'),
              SizedBox(width: 12),
              _Legend(SchooKeepColors.primary, 'Routine'),
              SizedBox(width: 12),
              _Legend(SchooKeepColors.warning, 'Reminder'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _usageRow(_DayUsage d) {
    final total = d.emergency + d.routine + d.reminder;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 40,
            child: Text(d.day, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (d.emergency > 0) _bar(SchooKeepColors.error, d.emergency / _maxTotal),
                  if (d.emergency > 0) const SizedBox(width: 2),
                  if (d.routine > 0) _bar(SchooKeepColors.primary, d.routine / _maxTotal),
                  if (d.routine > 0) const SizedBox(width: 2),
                  if (d.reminder > 0) _bar(SchooKeepColors.warning, d.reminder / _maxTotal),
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

  Widget _topUpCard() {
    final enabled = _topUpAmount.text.isNotEmpty;
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Funds',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
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
                      hintText: 'Enter credits',
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
                  child: Text('Add funds',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: enabled ? Colors.white : const Color(0xFF94A3B8))),
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

  Widget _transactionHistory(List<SmsTransaction> transactions) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction History',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No transactions yet',
                  style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
            )
          else
            for (int i = 0; i < transactions.length; i++)
              _txRow(transactions[i], i < transactions.length - 1),
        ],
      ),
    );
  }

  Widget _txRow(SmsTransaction tx, bool divider) {
    final isTopup = tx.type == 'topup';
    final title = tx.description ?? (isTopup ? 'Top-up' : 'SMS charge');
    final amount = '${isTopup ? '+' : '-'}${tx.credits} credits';
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
